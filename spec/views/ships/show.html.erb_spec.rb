require 'spec_helper'

describe "ships/show.html.erb" do
  before(:each) do
    @ship = assign(:ship, stub_model(Ship,
      :name => "Name",
      :dwt => 1,
      :built_year => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
