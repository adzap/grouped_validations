module GroupedValidations

  module ClassMethods

    def define_group_validation_callbacks(group)
      define_callbacks :"validate_#{group}", :scope => 'validate'
    end

    def validate_with_groups(*args, &block)
      if @current_validation_group
        options = args.last
        if options.is_a?(Hash) && options.key?(:on)
          options[:if] = Array(options[:if])
          options[:if] << "@_on_validate == :#{options[:on]}"
        end
        set_callback(:"validate_#{@current_validation_group}", *args, &block)
      else
        validate_without_groups(*args, &block)
      end
    end

  end

  module InstanceMethods

    def run_group_validation_callbacks(group)
      @_on_validate = new_record? ? :create : :update
      send(:"_run_validate_#{group}_callbacks")
    end

  end

end
