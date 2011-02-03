require "spec_helper"

describe ShipsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/ships" }.should route_to(:controller => "ships", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/ships/new" }.should route_to(:controller => "ships", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/ships/1" }.should route_to(:controller => "ships", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/ships/1/edit" }.should route_to(:controller => "ships", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/ships" }.should route_to(:controller => "ships", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/ships/1" }.should route_to(:controller => "ships", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/ships/1" }.should route_to(:controller => "ships", :action => "destroy", :id => "1")
    end

  end
end
