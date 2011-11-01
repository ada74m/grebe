require "rspec"

describe "And criterion" do

  it "should be a composite" do
    CompositeCriterion.and.should be_a_kind_of CompositeCriterion
  end

  it "should describe itself" do
    criterion = CompositeCriterion.and

    criterion.description.should == ''

    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    criterion.description.should == 'ship.dwt equals 100'

    criterion.children << (Equals.new :model => :ship, :property => 'built_year', :integer_a => 1981)
    criterion.description.should == '(ship.dwt equals 100 and ship.built_year equals 1981)'

  end

  it "should flip to negative form without changing meaning" do
    criterion = CompositeCriterion.and
    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    criterion.children << (Equals.new :model => :ship, :property => 'built_year', :integer_a => 1981)

    criterion.description.should == '(ship.dwt equals 100 and ship.built_year equals 1981)'

    criterion.translate_to_or_from_negative_form
    criterion.description.should == 'not (ship.dwt does not equal 100 or ship.built_year does not equal 1981)'

    criterion.translate_to_or_from_negative_form
    criterion.description.should == '(ship.dwt equals 100 and ship.built_year equals 1981)'
  end

  it "should flip to negative form without changing meaning when it is intrinsically negated" do
    root = CompositeCriterion.and :negative => true
    root.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    root.children << (child = CompositeCriterion.or)
    child.children << (Equals.new :model => :ship, :property => 'built_year', :integer_a => 1981)
    child.children << (Equals.new :model => :ship, :property => 'built_year', :integer_a => 1974)

    root.description.should == 'not (ship.dwt equals 100 and (ship.built_year equals 1981 or ship.built_year equals 1974))'

    root.translate_to_or_from_negative_form
    root.description.should == '(ship.dwt does not equal 100 or not (ship.built_year equals 1981 or ship.built_year equals 1974))'

    root.translate_to_or_from_negative_form
    root.description.should == 'not (ship.dwt equals 100 and (ship.built_year equals 1981 or ship.built_year equals 1974))'
  end

end