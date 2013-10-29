require_relative "../backsum"

require "cocaine"
require 'posix/spawn'

module Backsum
  class Shell
    def initialize(command, params = "", options = {})
      options[:runner] ||= LoggablePosixRunner.new
      @command_line = Cocaine::CommandLine.new(command, params, options)
    end

    def run(*args)
      @command_line.run(*args)
    end
  end

  class LoggablePosixRunner
    def call(command, env = {})
      input, output = IO.pipe
      pid = spawn(env, command, :out => output)
      output.close
      result = ""

      while line = input.readline 
        Backsum.logger.debug(line.chomp)
        result << line
      end rescue EOFError

      waitpid(pid)
      input.close
      result
    end

    def spawn(*args)
      ::POSIX::Spawn.spawn(*args)
    end

    def waitpid(pid)
      ::Process.waitpid(pid)
    end
  end
end