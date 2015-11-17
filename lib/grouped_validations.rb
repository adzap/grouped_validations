require 'active_model/validations'
require 'grouped_validations/active_model'
require 'grouped_validations/callback'

module GroupedValidations
  extend ActiveSupport::Concern

  included do
    class_attribute :validation_groups
    self.validation_groups = []
  end

  module ClassMethods

    def validate(*args, &block)
      return super unless @_current_validation_group

      options = args.extract_options!.dup
      unless @_current_validation_group[:with_options]
        options.reverse_merge!(@_current_validation_group.except(:name)) 
      end

      if options.key?(:on)
        options = options.dup
        options[:if] = Array.wrap(options[:if])
        options[:if] << "validation_context == :#{options[:on]}"
      end
      args << options
      set_callback(:"validate_#{@_current_validation_group[:name]}", *args, &block)
    end

    def _define_group_validation_callbacks(group)
      define_callbacks :"validate_#{group}", :scope => :callback_method, callback_method: :validate
    end

  end

  def valid?(context=nil)
    super
    validation_groups.each do |group|
      _run_group_validation_callbacks(group, context)
    end
    errors.empty?
  end

  def groups_valid?(*groups)
    options = groups.extract_options!
    errors.clear
    run_validations!
    groups.each do |group|
      raise "Validation group '#{group}' not defined" unless validation_groups.include?(group)
      _run_group_validation_callbacks(group, options[:context])
    end
    errors.empty?
  end
  alias_method :group_valid?, :groups_valid?

  def grouped_errors(context=nil)
    original_errors = @errors.dup if @errors
    @errors = nil
    grouped = {}

    with_validation_context(context) do
      run_callbacks(:validate)
      grouped[nil] = errors

      validation_groups.each do |group|
        @errors = nil
        run_callbacks(:"validate_#{group}")
        grouped[group] = errors
      end
    end
    grouped.values.all?(&:empty?) ? Hash.new { |h,k| {} if validation_groups.include?(k) } : grouped
  ensure
    @errors = original_errors
  end

  def _run_group_validation_callbacks(group, context=nil)
    with_validation_context(context) do
      run_callbacks(:"validate_#{group}")
    end
  end

  def with_validation_context(context)
    context ||= (persisted? ? :update : :create)
    current_context, self.validation_context = validation_context, context
    yield
  ensure
    self.validation_context = current_context
  end

end
