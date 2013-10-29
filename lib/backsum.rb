require "backsum/version"
require_relative "backsum/version"
require "active_support/core_ext/module"

module Backsum
  mattr_accessor :verbose
  @@verbose = false

end
