require 'optparse'
require_relative "version"
require_relative "project"
require "pry-nav"

module Backsum
  class Cli
    attr_accessor :options, :files
    
    def initialize
      self.options = { projects_path: "./projects" }
      self.files = []
    end
    
    def execute(argv = [])
      option_parser!(argv)

      if !self.files.empty?
        self.files.each { |file| perform(file) }
      end
      exit
    end
    
    def option_parser!(argv)
      
      option_parser ||= OptionParser.new do |opts|

        opts.banner = "Usage: #{File.basename($0)} [options] action ..."

        opts.on("-V", "--version",
          "Display the Backsum version, and exit."
        ) do
          stdout "Backsum v#{Backsum::VERSION}"
          exit
        end

        opts.on("--all[=PATH]", ::String,
          "excute all the files. (default './projects')"
        ) do |path|
          scan_all_files( path || self.options[:projects_path] )
        end

      end
      if argv.empty?
        stderr "Please specify one action to execute."
        stderr option_parser.help
        exit
      end
      
      option_parser.parse!(argv)
      
      self.files = argv if self.files.empty?
    end

    def scan_all_files(path = nil)

      if !File.directory?(path)
        stderr "this path: #{File.expand_path path} is not exist."
        exit
      end
      
      Dir.foreach(path) do |config|
        config_path = path + "/" + config
        self.files << config_path if (config != "." && config != ".." && !File.directory?(config_path))
      end
      
    end
    
    def perform(file)
      if !File.exist?(file)
        stderr "#{file} is not exist!"
        exit
      end
      
      project = Backsum::Project.dsl(File.read(file), file)
      project.perform
    end
  protected
    def stdout(*args)
      (@stdout || STDOUT).puts(*args)
    end
    
    def stderr(*args)
      (@stderr || STDERR).puts(*args)
    end
  end
end