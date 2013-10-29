require "virtus"
require "fileutils"
require "cocaine"
require "shellwords"

module Backsum
  class Server
    include Virtus.model
    
    attribute :host
    attribute :username
    attribute :local
    attribute :folders, Hash
    
    def connect
      return nil if local
      username ? "#{username}@#{host}" : host if host
    end
    
    def sync(backup_path)
      self.folders.each_pair do |folder, options|
        execute_rsync(backup_path, connect, folder, options)
      end
    end
    
    def execute_rsync(backup_path, connect, source, options)
      arguments = [ "--archive", "--delete" ]
      target_path = File.join(backup_path, self.host)
      
      if options[:as]
        target_path = File.join(target_path, options[:as])
      else
        arguments << "--relative"
      end
      
      FileUtils.mkdir_p target_path
      
      (options[:excluded] || []).each do |pattern|
        arguments << "--exclude=#{pattern}"
      end
      
      if connect
        arguments << "#{connect}:#{source}"
      else
        arguments << source
      end
      
      arguments << target_path
      
      copy_command = Cocaine::CommandLine.new("rsync", arguments.map {|arg| shell_param_escape(arg) }.join(' '))
      copy_command.run
      
    end
    
    def shell_param_escape(str)
      if str.include? " "
        "'" + str.gsub("'", "\\'") + "'" 
      else
        str
      end
    end
    
    class Dsl
      attr_accessor :instance

      def initialize(host, options = {}, &block)
        self.instance = Server.new
        self.instance.host = host
        self.instance.local = options[:local]
        self.instance.username = options[:username]
        
        instance_eval(&block) if block
      end
      
      def folder(path, options = {})
        self.instance.folders[path] = options
      end
    end
  end
end