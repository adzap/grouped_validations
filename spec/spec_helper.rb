$:.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/spec')

require 'rubygems'
require 'active_record'

require 'grouped_validations'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})

ActiveRecord::Schema.define(:version => 1) do
  create_table :people, :force => true do |t|
    t.string   :first_name
    t.string   :last_name
    t.integer  :sex
  end
end

class Person < ActiveRecord::Base
end

module SpecHelper
  def reset_class(klass, &block)
    name = klass.name.to_sym
    Object.send(:remove_const, name)
    Object.const_set(name, Class.new(ActiveRecord::Base))
    new_klass = Object.const_get(name)
    new_klass.class_eval &block if block_given?
  end
end

Spec::Runner.configure do |config|
  config.include SpecHelper
end
