require 'spec_helper'

describe Criterion do

  describe "when in a hierarchy" do

    before(:each) do
      @root = CompositeCriterion.and

      @root.children << (@or = CompositeCriterion.or)
      @or.children << (@built1974 = Equals.new :model => :ship, :property => :built_year, :integer_a => 1974)
      @or.children << (@built_1981 = Equals.new :model => :ship, :property => :built_year, :integer_a => 1981)
      @or.children << (@and = CompositeCriterion.and)
      @and.children << (Equals.new :model => :ship, :property => :cranes, :integer_a => 2)
      @and.children << (Equals.new :model => :ship, :property => :winches, :integer_a => 2)


      @root.children << (@dwtOneMill = Equals.new :model => :ship, :property => :dwt, :integer_a => 1000000)

      @root.save!
    end

    it "should know about its parent" do
      @or.parent.should == @root
    end

    it "should know about its children" do
      @root.children.should have(2).items
    end

    it "should describe itself" do
      @root.description.should == "((ship.built_year equals 1974 or ship.built_year equals 1981 or (ship.cranes equals 2 and ship.winches equals 2)) and ship.dwt equals 1000000)"
    end


    it "should stay the same when you reload" do
      original_description = @root.description
      copy = Criterion.find @root.id
      copy.description.should == original_description
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

  class Spy
    @messages = []

    def self.clear
      @messages = []
    end
    def self.inform message
      @messages << message
    end
    def self.messages
      @messages
    end
  end

  describe "on loading" do

    before(:each) do

      Spy.clear

      @root = CompositeCriterion.and :negative => true
      @root.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1981)
      @root.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1974)

      #@root.children << (nested_or = CompositeCriterion.or)
      #nested_or.children << (Equals.new :model => :ship, :property => :dwt, :integer_a => 3000)
      #nested_or.children << (Equals.new :model => :ship, :property => :dwt, :integer_a => 4000)

      @root.save!

      class CompositeCriterion

        alias :on_after_find_orig :on_after_find

        def on_after_find
          Spy.inform "before after_initialise was run, normal? was #{self.normal?}"
          on_after_find_orig
        end
      end
    end

    after(:each) do
      class CompositeCriterion
        alias :on_after_find :on_after_find_orig

      end
    end

    it "should be normal as it leaves database but not normal after being fully loaded" do
      @root.reload
      Spy.messages.should =~ ["before after_initialise was run, normal? was true"]
      @root.should_not be_normal
    end

  end

  describe "on saving" do

    before(:all) do

      Spy.clear

      @root = CompositeCriterion.and :negative => true
      @root.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1981)
      @root.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1974)

      class CompositeCriterion
        alias :on_before_save_orig :on_before_save

        def on_before_save
          on_before_save_orig
          Spy.inform "after before_save was run, normal? was #{self.normal?}"
        end
      end

    end

    after(:all) do

      class CompositeCriterion
        alias :on_before_save :on_before_save_orig
      end

    end

    it "should be normalised after before_save has run and denormalised again later" do
      @root.should_not be_normal
      Spy.messages.should =~ []
      @root.save
      Spy.messages.should =~ ["after before_save was run, normal? was true"]
      @root.should_not be_normal
    end
  end

end