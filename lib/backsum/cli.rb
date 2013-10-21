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
      self.files.each { |file| perform(file) }
    end
    
    def option_parser!(argv)
      
      option_parser ||= OptionParser.new do |opts|

        opts.banner = "Usage: #{File.basename($0)} [options] action ..."

        opts.on("-V", "--version",
          "Display the Backsum version, and exit."
        ) do
          stdout "Backsum v#{Backsum::VERSION}"
          exit 0
        end

        opts.on("--all[=PATH]", ::String,
          "excute all the files. (default is '#{self.options[:projects_path]}')"
        ) do |path|
          self.options[:projects_path] = path
          @scan_projects_dir = true
        end

      end
      if argv.empty?
        stderr "Please specify one action to execute."
        stderr option_parser.help
        exit 1
      end
      
      option_parser.parse!(argv)
      
      if @scan_projects_dir
        self.files = Dir[File.join(self.options[:projects_path], '*.rb')]
      else
        self.files = argv if self.files.empty?
      end

      self.files.each do |file|
        if !File.exist?(file)
          stderr "#{file} is not exist!"
          exit 1
        end
      end
    end
    
    def perform(file)
      project = Backsum::Project.dsl(File.read(file), file)
      project.perform
    end
  protected
    def stdout(*args)
      $stdout.puts(*args)
    end
    
    def stderr(*args)
      $stderr.puts(*args)
    end
  end
end