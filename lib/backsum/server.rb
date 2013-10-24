module Backsum
  class Server
    attr_accessor :host, :username, :folders
    
    def initialize(attributes = {})
      self.folders = {}
      attributes.each_pair do |name, value|
        send("#{name}=", value)
      end
    end
    
    class Dsl
      attr_accessor :instance

      def initialize(host, options = {}, &block)
        self.instance = Server.new
        self.instance.host = host
        self.instance.username = options[:username]
        
        instance_eval(&block) if block
      end
      
      def folder(path, options = {})
        self.instance.folders[path] = options
      end
    end
  end
end