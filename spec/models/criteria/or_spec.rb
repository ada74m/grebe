require "rspec"

describe "Or criterion" do

  it "should be a composite" do
    Or.new.should be_a_kind_of CompositeCriterion
  end


  it "should describe itself" do
    criterion = Or.new

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
    criterion = Or.new
    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 100)
    criterion.children << (Equals.new :model => :ship, :property => 'dwt', :integer_a => 200)

    criterion.description.should == '(ship.dwt equals 100 or ship.dwt equals 200)'

    criterion.toggle_negativity
    criterion.description.should == 'not (ship.dwt does not equal 100 and ship.dwt does not equal 200)'

    criterion.toggle_negativity
    criterion.description.should == '(ship.dwt equals 100 or ship.dwt equals 200)'

  end

end

