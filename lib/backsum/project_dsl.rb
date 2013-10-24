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
        self.instance = Project.new
        self.instance.name = File.basename(filename, ".rb") if filename
        
        instance_eval(content, filename, lineno) if content
        instance_eval(&block) if block
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
      
      def backup_to(path)
        self.instance.backup_to = path
      end
    end
    
  end
end