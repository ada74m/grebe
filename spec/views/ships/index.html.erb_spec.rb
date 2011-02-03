require 'spec_helper'

describe "ships/index.html.erb" do
  before(:each) do
    assign(:ships, [
      stub_model(Ship,
        :name => "Name",
        :dwt => 1,
        :built_year => 1
      ),
      stub_model(Ship,
        :name => "Name",
        :dwt => 1,
        :built_year => 1
      )
    ])
  end

  it "renders a list of ships" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
