require 'spec_helper'

describe Criterion do

  it "should be negatable" do

    criterion = Equals.new
    criterion.negative = true
    criterion.should be_negative
  end

  describe "behaviour when in a hierarchy" do

    before(:each) do
      @root = CompositeCriterion.and

      @root.children << (@or = CompositeCriterion.or)
      @or.children << (@built1974 = Equals.new :model => :ship, :property => :built_year, :integer_a => 1974)
      @or.children << (@built_1981 = Equals.new :model => :ship, :property => :built_year, :integer_a => 1981)

      @root.children << (@dwtOneMill = Equals.new :model => :ship, :property => :dwt, :integer_a => 1000000 )

      @root.save!
    end

    it "should know about its parent" do
      @or.parent.should == @root
    end

    it "should know about its children" do
      @root.children.should have(2).items
    end

    it "should describe itself" do
      @root.description.should == "((ship.built_year equals 1974 or ship.built_year equals 1981) and ship.dwt equals 1000000)"
    end

  end

  describe "normalisation (i.e. pushing down negativity to leafs)" do

    before(:each) do

      @root = CompositeCriterion.and :negative => true
      @root.children << (@or = CompositeCriterion.or)
      @or.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1981)
      @or.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1974, :negative => true)

      @root.children << (@nor = CompositeCriterion.or :negative => true)
      @nor.children << (Equals.new  :model => :ship, :property => :dwt, :integer_a => 1000000)
      @nor.children << (Equals.new  :model => :ship, :property => :dwt, :integer_a => 2000000)

      @root.description.should == "not ((ship.built_year equals 1981 or ship.built_year does not equal 1974) and not (ship.dwt equals 1000000 or ship.dwt equals 2000000))"
    end

    it "should know when it is not in normal form" do
      @root.should_not be_normal
    end

    it "should push down the negativity into the leaves" do
      @root.normalise
      @root.description.should == "((ship.built_year does not equal 1981 and ship.built_year equals 1974) or (ship.dwt equals 1000000 or ship.dwt equals 2000000))"
    end

    it "should know when it is in normal form" do
      @root.normalise
      @root.should be_normal
    end

    it "should restore negativity" do
      @root.normalise
      @root.restore
      @root.description.should == "not ((ship.built_year equals 1981 or ship.built_year does not equal 1974) and not (ship.dwt equals 1000000 or ship.dwt equals 2000000))"
    end

  end

  describe "behaviour during save" do

    before(:each) do
      @root = CompositeCriterion.and :negative => true
      @root.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1981)
      @root.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1974)

      class CompositeCriterion
        def normal_directly_after_save=(value)
          @normal_directly_after_save = value
        end

        def normal_directly_after_save
          @normal_directly_after_save
        end

        alias :after_save_orig :after_save

        def after_save
          self.normal_directly_after_save = self.normal?
          after_save_orig
        end
      end
    end

    after(:each) do
      class CompositeCriterion
        def after_save
          after_save_orig
        end
      end
    end

    it "should be normalised before saving but not directly after" do
      @root.should_not be_normal
      @root.normal_directly_after_save.should be_nil

      @root.save

      @root.normal_directly_after_save.should be_true
      @root.should_not be_normal

    end
  end

  describe "behaviour during load" do

    before(:each) do
      @root = CompositeCriterion.and :negative => true
      @root.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1981)
      @root.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1974)

      class CompositeCriterion
        def normal_directly_out_of_database=(value)
          @normal_directly_out_of_database = value
        end

        def normal_directly_out_of_database
          @normal_directly_out_of_database
        end

        alias :after_initialize_orig :after_initialize

        def after_initialize
          self.normal_directly_out_of_database = self.normal?
          after_initialize_orig
        end
      end
    end

    after(:each) do
      class CompositeCriterion
        def after_initialize
          after_initialize_orig
        end
      end
    end


    it "should be normal as it leaves database but not normal after being fully loaded" do

    end

  end

end