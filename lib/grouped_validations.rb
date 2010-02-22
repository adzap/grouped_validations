module GroupedValidations

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      include InstanceMethods
      class_inheritable_accessor :validation_groups
      alias_method_chain :valid?, :groups
      class << self
        alias_method_chain :validation_method, :groups
      end
    end
  end

  module ClassMethods

    def validation_group(name, &block)
      raise "The validation_group method requires a block" unless block_given?

      self.validation_groups ||= []
      self.validation_groups << name

      base_name = :"validate_#{name}"
      define_callbacks base_name, :"#{base_name}_on_create", :"#{base_name}_on_update"

      @current_validation_group = name
      class_eval &block
      @current_validation_group = nil
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

    def group_valid?(name)
      raise "Validation group '#{name}' not defined" unless validation_groups.include?(name)

      errors.clear
      run_group_validation_callbacks name
      errors.empty?
    end

    def groups_valid?(*groups)
      errors.clear
      groups.each do |name|
        raise "Validation group '#{name}' not defined" unless validation_groups.include?(name)
        run_group_validation_callbacks name
      end
      errors.empty?
    end

    def valid_with_groups?
      valid_without_groups?
      (validation_groups || []).each do |group|
        run_group_validation_callbacks group
      end
      errors.empty?
    end

    def run_group_validation_callbacks(name)
      base_name = :"validate_#{name}"
      run_callbacks(base_name)
      if new_record?
        run_callbacks(:"#{base_name}_on_create")
      else
        run_callbacks(:"#{base_name}_on_update")
      end
    end

  end

end

ActiveRecord::Base.send :include, GroupedValidations
