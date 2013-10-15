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
  
  it "can append a server" do
    project = Backsum::Project::Dsl.new do
      server "bstar-pro-uat", username: "root" do
      end
    end.instance

    project.servers.size.should == 1
    project.servers.first.should be_a Backsum::Server
    
  end
end