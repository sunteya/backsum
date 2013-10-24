require_relative 'server'
require "fileutils"
require "cocaine"
require "virtus"

module Backsum
  class Project
    attr_accessor :name, :servers, :keep_days, :keep_weeks, :backup_to, :current_backup
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
    
    def current_backup_name
      self.current_backup
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
      
      cweeks_mapping = backups.group_by(&:cweek)
      cweeks_mapping.keys.sort.reverse.slice(0, self.keep_weeks).each do |cweek|
        cweeks_mapping[cweek].sort.last.outdated = false
      end
      
      days_mapping = backups.group_by(&:day)
      days_mapping.keys.sort.reverse.slice(0, self.keep_days).each do |day|
        days_mapping[day].sort.last.outdated = false
      end
      
      
      backups.each do |backup|
        FileUtils.rm_rf(backup.path) if backup.outdated?
      end
      
      # FileUtils.ln_s File.join(self.backup_to, self.current_backup), File.join(self.backup_to, "Latest")
    end
    
    
    class Backup
      include Virtus.model
      NAME_PATTERN = "%Y%m%dT%H%M%S"
      
      attribute :name
      attribute :base_dir
      attribute :outdated, Boolean
      
      def <=>(other)
        self.backup_at <=> other.backup_at
      end
      
      def backup_at
        DateTime.strptime(self.name, NAME_PATTERN)
      end
      
      def backup_at=(datetime)
        self.name = datetime.strftime(NAME_PATTERN)
      end
      
      def path
        File.join(self.base_dir, self.name)
      end
      
      def cweek
        self.backup_at.cweek
      end
      
      def day
        self.backup_at.day
      end
    end
  end
end