require 'active_model/validations'
require 'grouped_validations/active_model'

module GroupedValidations
  extend ActiveSupport::Concern

  included do
    class_inheritable_accessor :validation_groups
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
      options[:context] ||= (persisted? ? :update : :create)
      errors.clear
      groups.each do |group|
        raise "Validation group '#{group}' not defined" unless validation_groups.include?(group)
        _run_group_validation_callbacks(group, options[:context])
      end
      errors.empty?
    end
    alias group_valid? groups_valid?

    def _run_group_validation_callbacks(group, context=nil)
      current_context, self.validation_context = validation_context, context
      send(:"_run_validate_#{group}_callbacks")
    ensure
      self.validation_context = current_context
    end

  end
end
