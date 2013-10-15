require_relative 'server'

module Backsum
  class Project
    attr_accessor :name, :servers
    
    def initialize
      self.servers = []
    end
    
    class Dsl
      attr_accessor :instance

      def initialize(content = nil, filename = nil, lineno = nil, &block)
        self.instance = Project.new

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
    end
  end
end