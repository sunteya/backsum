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
  
  it "can set default project name by config file basename" do
    dsl = Backsum::Project::Dsl.new nil, "./projects/bak_balm.rb"
    dsl.instance.name.should == "bak_balm"
  end
  
  it "can set default backup properties" do
    dsl = Backsum::Project::Dsl.new nil, "./projects/bak_balm.rb"
    
    dsl.instance.keep_days.should == 3
    dsl.instance.keep_weeks.should == 4
    dsl.instance.backup_folder.should == "./backups/bak_balm"
  end
  
  it "can override default backup properties" do
    dsl = Backsum::Project::Dsl.new do
      keep_days 5
      keep_weeks 8
      backup_folder "./baks/foo"
    end
    
    dsl.instance.keep_days.should == 5
    dsl.instance.keep_weeks.should == 8
    dsl.instance.backup_folder.should == "./baks/foo"
  end
  
  it "can synchronize backup_folder with project name" do
    dsl = Backsum::Project::Dsl.new  do
      name "oox"
    end
    
    dsl.instance.backup_folder.should == "./backups/oox"
  end

  it "can initial a Project::Dsl instance" do
    project = Project.dsl
    project.should be_a Project
  end
end