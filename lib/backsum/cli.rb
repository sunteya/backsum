require 'optparse'
require 'pry-nav'
require_relative "version"
require_relative "project"

module Backsum
  class Cli
    attr_reader :argv
    
    def initialize(argv)
      @argv = argv.dup
    end

    def execute
      option_parser!
      
      if !File.exist?(@argv.first)
        warn "#{@argv.first} is not exist!"
        exit
      end
      
      project = Backsum::Project::Dsl.new(File.read(@argv.first), @argv.first).instance
      project.perform
      
    end
    
    def option_parser!
      option_parser ||= OptionParser.new(@argv) do |opts|
      
        opts.banner = "Usage: #{File.basename($0)} [options] action ..."

        opts.on("-V", "--version",
          "Display the Backsum version, and exit."
        ) do
          puts "Backsum v#{Backsum::VERSION}"
          exit
        end

        opts.on("-A", "--all",
          "excute all the files."
        ) do
          puts "excute all the files."
          # TODO
          exit
        end

      end

      if @argv.empty?
        warn "Please specify one action to execute."
        warn option_parser.help
        exit
      end

      option_parser.parse!

      if @argv.size > 1 
        warn "Please specify only one action to execute."
        exit
      end
      
    end
  end
end