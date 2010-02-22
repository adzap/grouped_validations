require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GroupedValidations do
  before do
    reset_class Person
  end

  it "should add validation_group class method" do
    Person.should respond_to(:validation_group)
  end

  it "should store defined validation group names" do
    Person.validation_group(:dummy) { }
    Person.validation_groups.should == [:dummy]
  end

  it "it should add group_valid? method which takes a group name param" do
    Person.validation_group(:dummy) { }
    p = Person.new
    p.group_valid?(:dummy)
  end

  it "should raise exception if valiation group not defined on group_valid check" do
    p = Person.new
    lambda { p.group_valid?(:dummy) }.should raise_exception
  end

  it "should run the validations defined inside the validation group" do
    Person.validation_group :name do
      validates_presence_of :first_name
      validates_presence_of :last_name
    end

    p = Person.new
    p.group_valid?(:name)
    p.should have(2).errors

    p.first_name = 'Dave'
    p.last_name = 'Smith'
    p.group_valid?(:name)
    p.should have(0).errors
  end

  it "should run all validation groups passed to groups_valid?" do
    Person.class_eval do
      validation_group :first_name_group do
        validates_presence_of :first_name
      end
      validation_group :last_name_group do
        validates_presence_of :last_name
      end
    end

    p = Person.new
    p.groups_valid?(:first_name_group, :last_name_group)
    p.should have(2).errors
  end

  it "should run all validation including groups when valid? method called" do
    Person.class_eval do
      validation_group :first_name_group do
        validates_presence_of :first_name
      end
      validation_group :last_name_group do
        validates_presence_of :last_name
      end

      validates_presence_of :sex
    end

    p = Person.new
    p.valid?
    p.should have(3).errors
  end

  it "should respect :on validation option" do
    Person.validation_group :name do
      validates_presence_of :first_name, :on => :create
      validates_presence_of :last_name, :on => :update
    end

    p = Person.new
    p.group_valid?(:name)
    p.should have(1).errors
    p.first_name = 'Dave'
    p.group_valid?(:name)
    p.should have(0).errors

    p.save.should be_true
    p.group_valid?(:name)
    p.should have(1).errors
    p.last_name = 'Smith'
    p.group_valid?(:name)
    p.should have(0).errors
  end
end
