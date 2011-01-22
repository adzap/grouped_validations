require 'spec_helper'

describe GroupedValidations do
  let(:person) { Person.new }

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
    
    person.group_valid?(:dummy)
  end

  context ".group_valid?" do
    it "should run the validations defined inside the validation group" do
      Person.validation_group :name do
        validates_presence_of :first_name
        validates_presence_of :last_name
      end
      
      person.group_valid?(:name)
      person.should have(2).errors

      person.first_name = 'Dave'
      person.last_name = 'Smith'
      person.group_valid?(:name)
      person.should have(0).errors
    end

    it "should raise exception if valiation group not defined" do
      
      lambda { person.group_valid?(:dummy) }.should raise_exception
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
      
      person.groups_valid?(:first_name_group, :last_name_group)
      person.should have(2).errors
    end

    context "with validation context" do
      it "should run only validations for explicit context" do
        Person.validation_group :name do
          validates_presence_of :last_name, :on => :update
        end
        
        person.persisted = false
        person.last_name = nil
        person.group_valid?(:name, :context => :create)
        person.should have(0).errors

        person.persisted = true
        person.group_valid?(:name, :context => :update)
        person.should have(1).errors
        person.last_name = 'Smith'
        person.group_valid?(:name)
        person.should have(0).errors
      end

      it "should run only validations for implicit model context" do
        Person.validation_group :name do
          validates_presence_of :first_name, :on => :create
        end

        person.persisted = false
        person.group_valid?(:name)
        person.should have(1).errors
        person.first_name = 'Dave'
        person.group_valid?(:name)
        person.should have(0).errors

        person.persisted = true
        person.first_name = nil
        person.group_valid?(:name)
        person.should have(0).errors
      end

    end
  end

  context "group options" do
    it 'should pass option for group to validations' do
      Person.validation_group(:name, :if => lambda {|r| r.last_name.nil? }) do
        validates_presence_of :first_name
      end

      person.group_valid?(:name)
      person.should have(1).errors
      person.last_name = 'Smith'
      person.group_valid?(:name)
      person.should have(0).errors
    end

    it 'should not override existing validation options' do
      Person.validation_group(:name, :if => lambda {|r| r.last_name.nil? }) do
        validates_presence_of :first_name, :if =>  lambda { false }
      end

      person.group_valid?(:name)
      person.should have(0).errors
    end
  end

  describe "#grouped_errors" do
    before do
      Person.class_eval do
        validation_group :first_name_group do
          validates_presence_of :first_name
        end
        validation_group :last_name_group do
          validates_presence_of :last_name
        end
        validates_presence_of :sex
      end
    end

    it 'should return hash of error hashes with validation groups as keys' do
      person.valid?
      errors = person.grouped_errors
      errors[:first_name_group].should == {:first_name => ["can't be blank"]}
      errors[:last_name_group].should  == {:last_name  => ["can't be blank"]}
    end

    it 'should return hash of errors for validations outside a validation group, for nil key' do
      person.valid?
      errors = person.grouped_errors
      errors[nil][:sex].should == ["can't be blank"]
    end

  end

  # Can no longer be done. Unless I find a work around.
  # it "should allow a validation group to appended with subsequent blocks" do
  #   Person.class_eval do
  #     validation_group :name do
  #       validates_presence_of :first_name
  #     end
  #     validation_group :name do
  #       validates_presence_of :last_name
  #     end
  #   end

  #   
  #   person.group_valid?(:name)
  #   puts person.errors.inspect
  #   person.should have(2).errors
  # end

end
