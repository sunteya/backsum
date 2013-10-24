require "virtus"

module Backsum
  class Backup
    include Virtus.model
    NAME_PATTERN = "%Y%m%dT%H%M%S"
    
    attribute :name
    attribute :base_dir
    attribute :outdated, Boolean
    
    def <=>(other)
      self.backup_at <=> other.backup_at
    end
    
    def backup_at
      DateTime.strptime(self.name, NAME_PATTERN)
    end
    
    def backup_at=(datetime)
      self.name = datetime.strftime(NAME_PATTERN)
    end
    
    def path
      File.join(self.base_dir, self.name)
    end
    
    def cweek
      self.backup_at.cweek
    end
    
    def day
      self.backup_at.day
    end
  end
end