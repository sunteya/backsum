require_relative "../backsum"
require_relative "version"
require_relative "project_dsl"

require 'optparse'
require "virtus"

module Backsum
  class Cli
    attr_accessor :options, :action

    def initialize(*args)
      self.options = { projects_path: "./projects" }
      self.action = nil
    end
    
    def execute(argv = [])
      option_parser!(argv)

      if self.action
        send self.action
      else
        self.show_usage
        exit 1
      end
    end
    
    def option_parser!(argv)
      @option_parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options] action ..."

        opts.on("-V", "--version", "Display the Backsum version and exit.") do
          self.action = :show_version
        end

        opts.on("--all[=PATH]", "excute all the files. default: '#{self.options[:projects_path]}'") do |path|
          self.options[:projects_path] = path if path
          self.action = :perform_by_dir
        end

        opts.on("-v", "--[no-]verbose", "increase verbosity. default: #{Backsum.verbose}") do |v|
          Backsum.verbose = v
        end
      end

      @option_parser.parse!(argv)

      if !self.action && argv.any?
        self.action = :perform_by_inputs
        @input_files = argv
      end
    end
    
    def show_usage
      stderr "Please specify one action to execute."
      stderr @option_parser.help
    end

    def show_version
      stdout "Backsum v#{Backsum::VERSION}"
    end

    def perform_by_dir
      files = Dir[File.join(self.options[:projects_path], '*.rb')]
      perform_files(files)
    end

    def perform_by_inputs
      perform_files(@input_files)
    end

  protected
    def perform_files(files)
      files.each do |file|
        if !File.exist?(file)
          stderr "#{file} is not exist!"
          exit 1
        end
      end

      files.each do |file|
        project = Backsum::Project.dsl(File.read(file), file)
        project.perform
      end
    end

    def stdout(*args)
      $stdout.puts(*args)
    end
    
    def stderr(*args)
      $stderr.puts(*args)
    end
  end
end