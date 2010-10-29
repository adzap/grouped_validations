require 'rspec'

require 'active_support'
require 'active_model'

require 'grouped_validations'

class TestModel
  include ActiveSupport::Callbacks
  include ActiveModel::Validations

  def persisted?; false; end
end

class Person < TestModel
  attr_accessor :first_name, :last_name, :sex
end

module SpecHelper
  def reset_class(klass, &block)
    superklass = klass.superclass
    name = klass.name.to_sym
    Object.send(:remove_const, name)
    Object.const_set(name, Class.new(superklass))
    new_klass = Object.const_get(name)
    new_klass.class_eval &block if block_given?
  end
end

RSpec.configure do |config|
  config.include SpecHelper
end
