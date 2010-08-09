module GroupedValidations

  module ClassMethods

    def define_group_validation_callbacks(group)
      define_callbacks :"validate_#{group}", :terminator => "result == false", :scope => 'validate'
    end

    def validate_with_groups(*args, &block)
      if @current_validation_group
        options = args.last
        if options.is_a?(Hash) && options.key?(:on)
          options[:if] = Array(options[:if])
          options[:if] << "self.validation_context == :#{options[:on]}"
        end
        set_callback(:"validate_#{@current_validation_group}", *args, &block)
      else
        validate_without_groups(*args, &block)
      end
    end

  end

  module InstanceMethods

    def valid_with_groups?(context=nil)
      valid_without_groups?(context)
      (validation_groups || []).each do |group|
        run_group_validation_callbacks group
      end
      errors.empty?
    end

    def run_group_validation_callbacks(group)
      current_context, self.validation_context = validation_context, (new_record? ? :create : :update)
      send(:"_run_validate_#{group}_callbacks")
    ensure
      self.validation_context = current_context
    end

  end

end
