module GroupedValidations

  module ClassMethods

    def validation_group(group, &block)
      raise "The validation_group method requires a block" unless block_given?

      self.validation_groups ||= []
      self.validation_groups << group

      define_group_validation_callbacks group

      @current_validation_group = group
      class_eval &block
      @current_validation_group = nil
    end

  end

  module InstanceMethods

    def group_valid?(group)
      raise "Validation group '#{group}' not defined" unless validation_groups.include?(group)

      errors.clear
      run_group_validation_callbacks group
      errors.empty?
    end

    def groups_valid?(*groups)
      errors.clear
      groups.each do |group|
        raise "Validation group '#{group}' not defined" unless validation_groups.include?(group)
        run_group_validation_callbacks group
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

  end

end

ActiveRecord::Base.class_eval do
  extend GroupedValidations::ClassMethods
  include GroupedValidations::InstanceMethods
  class_inheritable_accessor :validation_groups
  alias_method_chain :valid?, :groups
end

if ActiveRecord::VERSION::MAJOR == 3
  require 'grouped_validations/active_model'
  ActiveRecord::Base.class_eval do
    class << self
      alias_method_chain :validate, :groups
    end
  end
else
  require 'grouped_validations/active_record'
  ActiveRecord::Base.class_eval do
    class << self
      alias_method_chain :validation_method, :groups
    end
  end
end
