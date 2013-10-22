require_relative 'server'

module Backsum
  class Project
    attr_accessor :name, :servers, :keep_days, :keep_weeks, :backup_folder
    
    def initialize
      self.servers = []
    end
    
    def backup_folder
      @backup_folder.respond_to?(:call) ? instance_eval(&@backup_folder) :  @backup_folder.to_s
    end
    
    def perform
    end
    
  end
end