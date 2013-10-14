require_relative '../../spec_helper'
require "backsum/project"

describe Backsum::Project do
  
  it "can create instance by dsl" do
    project = Backsum::Project::Dsl.new do
      name "github.com"
    end.instance
    
    project.name.should == "github.com"
  end

end