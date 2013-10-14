module Backsum
  class Project
    attr_accessor :name

    class Dsl
      attr_accessor :instance

      def initialize(&block)
        self.instance = Project.new
        instance_eval(&block) if block
      end
      
      def name(name)
        self.instance.name = name
      end
      
    end
  end
end