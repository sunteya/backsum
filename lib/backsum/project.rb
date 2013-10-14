module Backsum
  class Project
    attr_accessor :name

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
      
    end
  end
end