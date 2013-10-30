require_relative '../../spec_helper'
require "backsum/server"
require "pathname"

describe Server do
  
  before(:each) do
    @fixture_dir = Pathname.new("../server_spec").expand_path(__FILE__)
    @autoremove_files = []
  end
  
  after(:each) do
    @autoremove_files.each do |file|
      FileUtils.rm_rf(file) if File.exist?(file)
    end
  end

  it "can create instance by dsl block" do
    server = Server::Dsl.new "localhost", username: "root" do
      folder "/balm/shared", excluded: [ "logs" ]
      folder "/balm-games/shared"
    end.instance

    server.host.should == "localhost"
    server.username.should == "root"
    server.folders.size.should == 2
    server.folders["/balm/shared"].should == {:excluded => ["logs"]}
    server.folders["/balm-games/shared"].should == {}
  end
  
  it "can sync folder from localhost" do
    source_dir = @fixture_dir.join("source_first/")
    target_dir = @fixture_dir.join("target_first/")
    @autoremove_files << target_dir.to_s
    
    server = Server::Dsl.new "localhost", local: true do
      folder source_dir.to_s, excluded: [ "folder2" ]
    end.instance
    server.sync target_dir.to_s, nil
    source_relative_dir = source_dir.relative_path_from(Pathname.new("/"))
    target_dir.join(server.host, source_relative_dir, "folder1").should be_exist
    target_dir.join(server.host, source_relative_dir, "folder2").should_not be_exist
  end
  
  it "can sync folder from localhost incrementally" do
    source_dir = @fixture_dir.join("source_increment")
    target_dir = @fixture_dir.join("target_increment")
    linkdest_dir = @fixture_dir.join("target_increment_latest")
    linkdest_path = "./spec/lib/backsum/server_spec/target_increment_latest"
    @autoremove_files << target_dir.to_s
    
    server = Server::Dsl.new "localhost", local: true do
      folder source_dir.to_s , as: "folder1"
    end.instance
    
    server.sync target_dir.to_s, linkdest_path
    
    target_dir.join(server.host, "folder1", "file1").should be_exist
    File.identical?(target_dir.join(server.host, "folder1", "file1"), linkdest_dir.join(server.host, "folder1", "file1")).should be_true
    target_dir.join(server.host, "folder1", "file2").should be_exist
  end
  
end