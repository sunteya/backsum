require_relative '../../spec_helper'
require "backsum/project"

describe Backsum::Project do
  
  it "can create instance by dsl block" do
    project = Backsum::Project::Dsl.new do
      name "github.com"
    end.instance

    project.name.should == "github.com"
  end

  it "can create instance by dsl file" do
    dsl = Backsum::Project::Dsl.new <<-end_eval, __FILE__, __LINE__
      name "ooxx"
    end_eval

    dsl.instance.name.should == "ooxx"
  end

end