require 'spec_helper'

describe Criterion do

  it "should know about its parent" do

    parent = Criterion.new :type => :and
    child = Criterion.new :type => :equal, :model => :ship, :property => :dwt, :integer_a => 3000

    child.should be_valid

  end

end



