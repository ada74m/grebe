require 'spec_helper'

describe Equals do

  it "should have 'equals' as its type" do

    criterion = Equals.new
    criterion.type.should == "Equals"

  end

  it "should be invalid without model" do
    criterion = Equals.new
    criterion.should_not be_valid
    criterion.errors.should include :model => ["can't be blank"]
  end

  it "should be invalid without property" do
    criterion = Equals.new
    criterion.should_not be_valid
    criterion.errors.should include :property => ["can't be blank"]
  end


  it "should describe itself" do
    Equals.new(
      :model => 'ship',
      :property => 'dwt',
      :integer_a => 30000
  ).description.should == "ship.dwt equals 30000"

  end

end


