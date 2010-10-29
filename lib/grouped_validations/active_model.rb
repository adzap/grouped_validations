module ActiveModel
  module Validations

    module ClassMethods

      def validation_group(group, &block)
        raise "The validation_group method requires a block" unless block_given?

        unless include?(GroupedValidations)
          include GroupedValidations
        end

        self.validation_groups ||= []
        self.validation_groups << group

        _define_group_validation_callbacks(group)

        @current_validation_group = group
        class_eval &block
        @current_validation_group = nil
      end

    end

  end
end
