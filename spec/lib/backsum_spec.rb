require_relative '../spec_helper'
require "backsum"

describe Backsum do
  it "have a version" do
    Backsum::VERSION.should be_a String
  end
end