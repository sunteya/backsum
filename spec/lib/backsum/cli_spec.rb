require_relative '../../spec_helper'
require "backsum/cli"

describe Backsum::Cli do
  before(:each) do
    @stdout, @stderr = capture_console_output
    @fixture_dir = File.expand_path("../cli_spec", __FILE__)
    @cli = Cli.new
    @project = double("project")
    
    Project.should respond_to(:dsl)
    Project.stub(:dsl).with(any_args).and_return(@project)
  end

  after(:each) do
    release_console_capture
  end

  it "can show corrent version" do
    exit_code = run_command "-V"
    exit_code.should == 0
    @stdout.string.should include Backsum::VERSION
  end
  
  it "can show help with null arguments" do
    exit_code = run_command
    exit_code.should_not == 0
    @stderr.string.should_not be_empty
  end
  
  it "have verbose option" do
    exit_code = run_command "--verbose"
    Backsum.verbose.should == true
    Backsum.logger.level.should == Logging.level_num(:debug)
  end

  it "can't recieve unexists file" do
    exit_code = run_command "./unexists_file.rb"
    exit_code.should_not == 0
    @stderr.string.should_not be_empty
  end
  
  it "can execute perform method with existing file" do
    @project.should receive(:perform).once
    Dir.chdir(@fixture_dir) do
      exit_code = run_command "all-projects/uat.rb"
      exit_code.should == 0
    end
  end
  

  it "the argument '--all' have default value" do
    Dir.chdir(@fixture_dir) do
      exit_code = run_command "--all"
    end
    @cli.options[:projects_path].should == "./projects"
  end

  it "can execute command with option --all" do
    @project.should receive(:perform).twice
    Dir.chdir(@fixture_dir) do
      exit_code = run_command "--all=./all-projects"
      exit_code.should == 0
    end

    @cli.options[:projects_path].should == "./all-projects"
  end
  
  it "can ignore FILE argument if have argument: '--all'" do
    @project.should receive(:perform).twice
    Dir.chdir(@fixture_dir) do
      exit_code = run_command "--all=./all-projects" , "./ignore_file.rb"
      exit_code.should == 0
    end
  end
  
protected
  def run_command(*argv)
    begin
      @cli.execute(argv)
      return 0
    rescue SystemExit => e
      return e.status
    end
  end

  def capture_console_output(&block)
    @capture_console_output_start = true
    @origin_stdout = $stdout
    @origin_stderr = $stderr

    stdout = StringIO.new
    stderr = StringIO.new

    $stdout = stdout
    $stderr = stderr

    if block_given?
      begin
        result = yield
        [ stdout, stderr, result ]
      ensure
        release_console_capture
      end
    else
      [ stdout, stderr ]
    end
  end

  def release_console_capture
    if @capture_console_output_start
      $stdout = @origin_stdout
      $stderr = @origin_stderr
      @capture_console_output_start = false
    end
  end

end