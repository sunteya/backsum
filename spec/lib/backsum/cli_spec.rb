require_relative '../../spec_helper'
require "backsum/cli"
require "backsum/version"

describe Backsum::Cli do
  before(:each) do
    @cli = Cli.new
    @stdout = StringIO.new
    @stderr = StringIO.new
    @cli.instance_variable_set("@stdout", @stdout)
    @cli.instance_variable_set("@stderr", @stderr)
    @fixture_dir = File.dirname(__FILE__) + "/" + File.basename(__FILE__, File.extname(__FILE__))
    
    @project = double("project")
    allow(@project).to receive(:perform)
    allow(Project).to receive(:dsl) { @project }
  end

  it "can show corrent version" do
    run_command([ "-V" ])
    @stdout.string.should include Backsum::VERSION
  end
  
  it "can show help with null arguments" do
    run_command
    @stderr.string.should include "Please specify one action to execute."
  end
  
  it "can't recieve unexists file" do
    unexists_file = "./aaaa.rb"
    run_command([ unexists_file ])
    @stderr.string.should include "#{unexists_file} is not exist!"
  end
  
  it "can execute perform method with existing file" do
    @project.should receive(:perform).once
    Dir.chdir(@fixture_dir) do
      run_command([ "./all-projects/uat.rb" ])
    end
  end
  
  it "can execute command with option --all" do
    @project.should receive(:perform).twice
    Dir.chdir(@fixture_dir) do
      run_command([ "--all=./all-projects" ])
    end
  end
  
  it "can't receive argument:--all and actions at the some time" do
    @project.should receive(:perform).twice
    Dir.chdir(@fixture_dir) do
      run_command([ "--all=./all-projects" , "./all-projects/uat.rb", "./all-projects/mh.rb"])
    end
  end
  
private
  def run_command(argv = [])
    expect { @cli.execute(argv) }.to raise_error
  end
end