require 'spec_helper'

describe "ships/edit.html.erb" do
  before(:each) do
    @ship = assign(:ship, stub_model(Ship,
      :name => "MyString",
      :dwt => 1,
      :built_year => 1
    ))
  end

  it "renders the edit ship form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => ship_path(@ship), :method => "post" do
      assert_select "input#ship_name", :name => "ship[name]"
      assert_select "input#ship_dwt", :name => "ship[dwt]"
      assert_select "input#ship_built_year", :name => "ship[built_year]"
    end
  end
end
