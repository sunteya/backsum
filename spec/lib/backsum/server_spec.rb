require_relative '../../spec_helper'
require "backsum/server"

describe Backsum::Server do
  
  it "can create instance by dsl block" do
    server = Backsum::Server::Dsl.new "localhost", username: "root" do
      folder "/balm/shared", excludes: [ "logs" ]
      folder "/balm-games/shared"
    end.instance

    server.host.should == "localhost"
    server.username.should == "root"
    server.folders.size.should == 2
    server.folders["/balm/shared"].should == {:excludes => ["logs"]}
    server.folders["/balm-games/shared"].should == {}
  end
end