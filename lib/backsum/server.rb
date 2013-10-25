require "virtus"

module Backsum
  class Server
    include Virtus.model
    
    attribute :host
    attribute :username
    attribute :folders, Hash
    
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