require "rspec"

describe "Or criterion" do

  it "should be a composite" do
    CompositeCriterion.or.should be_a_kind_of CompositeCriterion
  end


  it "should describe itself" do
    criterion = CompositeCriterion.or

    criterion.description.should == ''

    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    criterion.description.should == 'ship.dwt equals 100'

    criterion.negative = true
    criterion.description.should == 'not (ship.dwt equals 100)'


    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 200)
    criterion.description.should == 'not (ship.dwt equals 100 or ship.dwt equals 200)'

    criterion.negative = false
    criterion.description.should == '(ship.dwt equals 100 or ship.dwt equals 200)'


  end


  it "should flip to negative form without changing meaning" do
    criterion = CompositeCriterion.or
    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 200)

    criterion.description.should == '(ship.dwt equals 100 or ship.dwt equals 200)'

    criterion.translate_to_or_from_negative_form
    criterion.description.should == 'not (ship.dwt does not equal 100 and ship.dwt does not equal 200)'

    criterion.translate_to_or_from_negative_form
    criterion.description.should == '(ship.dwt equals 100 or ship.dwt equals 200)'

  end

  it "should flip to negative form without changing meaning when it is intrinsically negated" do
    criterion = CompositeCriterion.or :negative => true
    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 200)

    criterion.description.should == 'not (ship.dwt equals 100 or ship.dwt equals 200)'

    criterion.translate_to_or_from_negative_form
    criterion.description.should == '(ship.dwt does not equal 100 and ship.dwt does not equal 200)'

    criterion.translate_to_or_from_negative_form
    criterion.description.should == 'not (ship.dwt equals 100 or ship.dwt equals 200)'

  end

end

