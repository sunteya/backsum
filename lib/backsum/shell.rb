require "cocaine"

module Backsum
  class Shell
    def initialize(command, params = "", options = {})
      @command_line = Cocaine::CommandLine.new(command, params, options)
    end

    def run(*args)
      @command_line.run(*args)
    end
  end
end