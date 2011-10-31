require "rspec"

describe "And criterion" do

  it "should be a composite" do

    And.new.should be_a_kind_of CompositeCriterion
  end

  it "should describe itself" do
    criterion = And.new

    criterion.description.should == ''

    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    criterion.description.should == 'ship.dwt equals 100'

    criterion.children << (Equals.new :model => :ship, :property => 'built_year', :integer_a => 1981)
    criterion.description.should == '(ship.dwt equals 100 and ship.built_year equals 1981)'

  end

  it "should flip to negative form without changing meaning" do
    criterion = And.new
    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    criterion.children << (Equals.new :model => :ship, :property => 'built_year', :integer_a => 1981)

    criterion.description.should == '(ship.dwt equals 100 and ship.built_year equals 1981)'

    criterion.toggle_negativity
    criterion.description.should == 'not (ship.dwt does not equal 100 or ship.built_year does not equal 1981)'

    criterion.toggle_negativity
    criterion.description.should == '(ship.dwt equals 100 and ship.built_year equals 1981)'
  end

  it "should flip to negative form without changing meaning when it is intrinsically negated" do
    criterion = And.new :negative => true
    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    criterion.children << (Equals.new :model => :ship, :property => 'built_year', :integer_a => 1981)

    criterion.description.should == 'not (ship.dwt equals 100 and ship.built_year equals 1981)'

    criterion.toggle_negativity
    criterion.description.should == '(ship.dwt does not equal 100 or ship.built_year does not equal 1981)'

    criterion.toggle_negativity
    criterion.description.should == 'not (ship.dwt equals 100 and ship.built_year equals 1981)'
  end

end