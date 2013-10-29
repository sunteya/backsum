require_relative "backsum/version"
require "active_support/core_ext/module"
require "logging"

module Backsum
  mattr_accessor :verbose
  @@verbose = false

  mattr_accessor :logger
  @@logger = Logging.logger($stdout).tap do |logger|
    logger.level = :info
  end

end
