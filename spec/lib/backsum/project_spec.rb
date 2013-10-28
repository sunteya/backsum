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
    current_backup_path = Pathname.new(project.current_backup.path)
    @autoremove_files << current_backup_path
    project.servers = [ Server.new(host: "host1") ]
    
    project.build_target_backup_folder
    
    current_backup_path.should be_exist
    current_backup_children = current_backup_path.each_child.map { |p| p.basename.to_s }
    current_backup_children.should == [ "host1" ]
  end
  
  it "can cleanup outdated daily backups" do
    deploy_dir = fixture_temp_dir("daliy_cleanup")
    backup_names = {
      "20131008T230000" => false,
      "20131009T220000" => false,
      "20131009T230000" => true,
      "20131010T220000" => false,
      "20131010T230000" => true
    }.each_pair do |datetime, result|
      FileUtils.mkdir_p deploy_dir.join(datetime)
    end
    
    project = Project.new(backup_to: deploy_dir, keep_days: 2, keep_weeks: 0)
    project.cleanup_outdate_backups
    
    backup_names.each_pair do |backup_name, result|
      deploy_dir.join(backup_name).exist?.should eq(result), backup_name
    end
  end
  
  it "can cleanup outdated weekly backups" do
    deploy_dir = fixture_temp_dir("daliy_cleanup")
    backup_names = {
      "20131006T000000" => false, # sun
      "20131009T000000" => false,
      "20131013T000000" => true, # sun
      "20131014T000000" => false, # mon
      "20131020T000000" => true  # sun
    }.each_pair do |datetime, result|
      FileUtils.mkdir_p deploy_dir.join(datetime)
    end
    
    project = Project.new(backup_to: deploy_dir, keep_days: 0, keep_weeks: 2)
    project.cleanup_outdate_backups
    
    backup_names.each_pair do |backup_name, result|
      deploy_dir.join(backup_name).exist?.should == result
    end
  end
  
  it "can regenerate sysmbol link after sync server" do
    third_backup_dir = fixture_temp_dir("third_time")
    backup_name = "20131020T153839"
    project = Project.new(backup_to: @fixture_dir.join("third_time"))
    
    FileUtils.mkdir_p File.join(project.backup_to, backup_name)
    project.current_backup.name = backup_name
    project.sync_servers_data
    
    File.readlink(File.join(project.backup_to, project.latest_link_name)).should == backup_name
  end
  
  def fixture_temp_dir(*basenames)
    path = @fixture_dir.join(*basenames)
    path.should_not be_exist
    @autoremove_files << path
    path
  end
  
end