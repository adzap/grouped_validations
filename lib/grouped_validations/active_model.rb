module ActiveModel
  module Validations

    module ClassMethods

      def validation_group(group, options={}, &block)
        raise "The validation_group method requires a block" unless block_given?

        unless include?(GroupedValidations)
          include GroupedValidations
        end

        unless validation_groups.include?(group)
          validation_groups << group
          _define_group_validation_callbacks(group)
        end

        options[:name] = group

        if block.arity == 1
          @_current_validation_group = options.merge(:with_options => true)
          
          with_options(options.except(:name)) do |config|
            yield config
          end
        else
          @_current_validation_group = options
          yield
        end
        @_current_validation_group = nil
      end

    end

  end
end
