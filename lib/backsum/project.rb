require_relative 'server'
require_relative 'backup'

require "fileutils"
require "cocaine"
require "virtus"

module Backsum
  class Project
    attr_accessor :name, :servers, :keep_days, :keep_weeks, :backup_to
    LATEST_LINK_NAME = "Latest"
    
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
      
      if self.latest_backup
        copy_command = Cocaine::CommandLine.new("cp", "-r -l :source :target")
        copy_command.run(source: self.latest_backup.path, target: self.current_backup.path)
      else
        FileUtils.mkdir_p(self.current_backup.path)
      end
      
      Dir[File.join(self.current_backup.path, "*")].each do |path|
        FileUtils.rm_rf path if !self.servers.any? {|s| s.host == File.basename(path) }
      end
    end
    
    def sync_servers_data
      
    end
    
    def current_backup
      @current_backup ||= Backup.new(backup_at: DateTime.now, base_dir: self.backup_to)
    end
    
    def latest_backup
      path = File.join(self.backup_to, LATEST_LINK_NAME)
      if File.exists?(path)
        real_path = File.readlink(path)
        Backup.new(name: File.basename(real_path), base_dir: self.backup_to)
      end
    end
    
    def latest_backup_name
      latest_path = File.join(self.backup_to, "Latest")
      File.readlink(self.backup_to)
    end
    
    def backups
      self.backup_names.map { |backup_name| Backup.new(name: backup_name, base_dir: self.backup_to) }
    end
    
    def backup_names
      Dir[File.join(self.backup_to, "*")].map do |backup_path|
        next if File.basename(backup_path) == LATEST_LINK_NAME
        File.basename(backup_path)
      end
    end
    
    def cleanup_outdate_backups
      backups = self.backups
      
      backups.each { |b| b.outdated = true }
      
      # keep weekly backups
      cweeks_mapping = backups.group_by(&:cweek)
      cweeks_mapping.keys.sort.reverse.slice(0, self.keep_weeks).each do |cweek|
        cweeks_mapping[cweek].sort.last.outdated = false
      end
      
      # keep daily backups
      days_mapping = backups.group_by(&:day)
      days_mapping.keys.sort.reverse.slice(0, self.keep_days).each do |day|
        days_mapping[day].sort.last.outdated = false
      end
      
      # keep latest backup
      # skip, already keep by daily
      
      backups.each do |backup|
        FileUtils.rm_rf(backup.path) if backup.outdated?
      end
    end
  end
end