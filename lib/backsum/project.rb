require_relative 'server'
require "fileutils"
require "cocaine"

module Backsum
  class Project
    attr_accessor :name, :servers, :keep_days, :keep_weeks, :backup_to, :current_backup
    
    def initialize(attributes = {})
      self.keep_days = 3
      self.keep_weeks = 4
      self.name = "default"
      self.backup_to = Proc.new { "./backups/#{name}" }
      self.servers = []
      
      attributes.each_pair do |name, value|
        send("#{name}=", value)
      end
    end
    
    def current_backup
      @current_backup || @current_backup = DateTime.now.strftime("%Y%m%dT%H%M%S")
    end
    
    def backup_to
      @backup_to.respond_to?(:call) ? instance_eval(&@backup_to) :  @backup_to.to_s
    end
    
    def perform
      build_target_backup_folder # prepare
      sync_servers_data # execute
      cleanup_outdate_backups # cleanup
    end
    
    def build_target_backup_folder
      FileUtils.mkdir_p(self.backup_to)
      Dir.chdir(self.backup_to) do
        latest_backup_folder = File.readlink("Latest") if File.exist?("Latest")
        current_backup_folder = self.current_backup
        
        if latest_backup_folder && File.exist?(latest_backup_folder)
          copy_command = Cocaine::CommandLine.new("cp", "-r -l :source :target")
          copy_command.run(source: latest_backup_folder, target: current_backup_folder)
        else
          FileUtils.mkdir_p(current_backup_folder)
        end
        
        Dir[File.join(current_backup_folder, "*")].each do |path|
          name = File.basename(path)
          FileUtils.rm_rf path if !self.servers.any? {|s| s.host == name }
        end
      end
    end
    
    def sync_servers_data
      
    end
    
    def cleanup_outdate_backups
      current_backup_folder = self.current_backup
      current_backup_date = DateTime.strptime(self.current_backup, "%Y%m%dT%H%M%S").to_date
      
      valid_folders = []
      valid_dates = {}
      
      self.keep_days.times do |i|
        valid_dates[current_backup_date.prev_day(i)] = []
      end
      
      self.keep_weeks.times do |i|
        valid_dates[(current_backup_date - current_backup_date.wday).prev_day(7 * i)] = []
      end
      
      Dir[File.join(self.backup_to, "*")].each do |path|
        next if File.symlink?(path)
        folder = File.basename(path)
        folder_backup_time = DateTime.strptime(folder, "%Y%m%dT%H%M%S")
        valid_dates[folder_backup_time.to_date] << folder_backup_time if valid_dates.include? folder_backup_time.to_date
      end
      
      valid_dates.each do |date, folders|
        valid_folders << folders.max.strftime("%Y%m%dT%H%M%S") if !folders.empty?
      end
      
      Dir[File.join(self.backup_to, "*")].each do |path|
        folder = File.basename(path)
        FileUtils.rm_r(path) if !valid_folders.include? folder
      end
      
      FileUtils.ln_s File.join(self.backup_to, current_backup_folder), File.join(self.backup_to, "Latest")
    end
    
  end
end