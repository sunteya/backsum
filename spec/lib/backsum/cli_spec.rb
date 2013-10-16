require_relative '../../spec_helper'
require "backsum/cli"
require "backsum/version"

describe Backsum::Cli do
  it "can show corrent version" do
    version = system "bin/backsum -V"
    version.should == true
  end
end