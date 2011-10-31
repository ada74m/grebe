require 'spec_helper'

describe Criterion do

  it "should be negatable" do

    criterion = Equals.new
    criterion.negative = true
    criterion.should be_negative
  end
end

describe "Criterion in a hierarchy" do

  before(:each) do
    @root = And.new

    @root.children << (@or = Or.new)
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

describe "Criterion hierarchy with negativity in composite nodes" do

  before(:each) do

    @nand = And.new :negative => true
    @nand.children << (@or = Or.new)
    @or.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1981)
    @or.children << (Equals.new :model => :ship, :property => :built_year, :integer_a => 1974)

    @nand.children << (@nor = Or.new :negative => true)
    @nor.children << (Equals.new  :model => :ship, :property => :dwt, :integer_a => 1000000)
    @nor.children << (Equals.new  :model => :ship, :property => :dwt, :integer_a => 2000000)



  end

  it "should push down the negativity into the leaves" do

    @nand.description.should == "not ((ship.built_year equals 1981 or ship.built_year equals 1974) and not (ship.dwt equals 1000000 or ship.dwt equals 2000000))"

  end

end