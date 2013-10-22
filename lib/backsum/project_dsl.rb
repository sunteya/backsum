require_relative 'project'
require_relative 'server'

module Backsum
  class Project
    
    def self.dsl(*args, &block)
      Dsl.new(*args, &block).instance
    end
    
    class Dsl
      attr_accessor :instance

      def initialize(content = nil, filename = nil, lineno = 0, &block)
        @filename = filename
        self.instance = Project.new
        self.apply_default_options
        
        instance_eval(content, filename, lineno) if content
        instance_eval(&block) if block
      end
      
      def apply_default_options
        self.instance.keep_days = 3
        self.instance.keep_weeks = 4
        self.instance.name = File.basename(@filename, ".rb") if @filename
        self.instance.backup_folder = Proc.new { "./backups/#{name}" }
      end
      
      def name(name)
        self.instance.name = name
      end
      
      def server(*args, &block)
        server = Server::Dsl.new(*args, &block).instance
        self.instance.servers << server
      end
      
      def keep_days(days)
        self.instance.keep_days = days
      end
      
      def keep_weeks(weeks)
        self.instance.keep_weeks = weeks
      end
      
      def backup_folder(path)
        self.instance.backup_folder = path
      end
    end
    
  end
end