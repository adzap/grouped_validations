require 'active_model/validations'
require 'grouped_validations/active_model'

module GroupedValidations
  extend ActiveSupport::Concern

  included do
    class_attribute :validation_groups
  end

  module ClassMethods

    def validate(*args, &block)
      if @current_validation_group
        options = args.extract_options!.dup
        options.reverse_merge!(@current_validation_group.except(:name))
        if options.key?(:on)
          options = options.dup
          options[:if] = Array.wrap(options[:if])
          options[:if] << "validation_context == :#{options[:on]}"
        end
        args << options
        set_callback(:"validate_#{@current_validation_group[:name]}", *args, &block)
      else
        super
      end
    end

    def _define_group_validation_callbacks(group)
      define_callbacks :"validate_#{group}", :scope => 'validate'
    end

  end

  module InstanceMethods

    def valid?(context=nil)
      super
      if validation_groups
        validation_groups.each do |group|
          _run_group_validation_callbacks(group, context)
        end
      end
      errors.empty?
    end

    def groups_valid?(*groups)
      options = groups.extract_options!
      errors.clear
      groups.each do |group|
        raise "Validation group '#{group}' not defined" unless validation_groups.include?(group)
        _run_group_validation_callbacks(group, options[:context])
      end
      errors.empty?
    end
    alias group_valid? groups_valid?

    def grouped_errors(context=nil)
      return errors if errors.empty?

      original_errors = @errors.dup
      @errors = nil
      grouped = {}

      with_validation_context(context) do
        _run_validate_callbacks
        grouped[nil] = @errors

        validation_groups && validation_groups.each do |group|
          @errors = nil
          send(:"_run_validate_#{group}_callbacks")
          grouped[group] = @errors
        end
      end
      grouped
    ensure
      @errors = original_errors
    end

    def _run_group_validation_callbacks(group, context=nil)
      with_validation_context(context) do
        send(:"_run_validate_#{group}_callbacks")
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
end
