module GroupedValidations

  module ClassMethods

    def define_group_validation_callbacks(group)
      base_name = :"validate_#{group}"
      define_callbacks base_name, :"#{base_name}_on_create", :"#{base_name}_on_update"
    end

    def validation_method_with_groups(on)
      if @current_validation_group
        base_name = :"validate_#{@current_validation_group}"
        case on
          when :save   then base_name
          when :create then :"#{base_name}_on_create"
          when :update then :"#{base_name}_on_update"
        end
      else
        validation_method_without_groups on
      end
    end

  end

  module InstanceMethods

    def run_group_validation_callbacks(group)
      base_name = :"validate_#{group}"
      run_callbacks(base_name)
      if new_record?
        run_callbacks(:"#{base_name}_on_create")
      else
        run_callbacks(:"#{base_name}_on_update")
      end
    end

  end

end
