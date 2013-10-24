require_relative '../../spec_helper'
require "backsum/project"
require "pathname"

describe Project do
  
  before(:each) do
    @fixture_dir = Pathname.new("../project_spec").expand_path(__FILE__)
    @autoremove_files = []
  end
  
  after(:each) do
    @autoremove_files.each do |file|
      FileUtils.rm_rf(file) if File.exist?(file)
    end
  end
  
  it "can build new target backup folders at first time" do
    first_backup_dir = fixture_temp_dir("first_time")
    
    project = Project.new(backup_to: first_backup_dir.to_s)
    project.build_target_backup_folder
    
    first_backup_dir.should be_exist
  end
  
  it "can copy to current backup folder and clean" do
    project = Project.new(backup_to: @fixture_dir.join("second_time"))
    project.current_backup = "20130101T000000"
    current_backup_dir = fixture_temp_dir("second_time", "20130101T000000")
    project.servers = [ Server.new(host: "host1") ]
    
    project.build_target_backup_folder
    
    current_backup_dir.should be_exist
    current_backup_children = current_backup_dir.each_child.map { |p| p.basename.to_s }
    current_backup_children.should == [ "host1" ]
  end
  
  def fixture_temp_dir(*basenames)
    path = @fixture_dir.join(*basenames)
    path.should_not be_exist
    @autoremove_files << path
    path
  end
  
end