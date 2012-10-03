class Screenshot < ActiveRecord::Base
  belongs_to :check_run
  belongs_to :step
  
  validates_presence_of :checksum
  
  after_destroy :release
  after_create :retain
  
  attr_writer :file
  
  def self.from_param!(param)
    find(param)
  end
  
  def file
    @file ||= ScreenshotFile.new(checksum)
  end
  
  delegate :file_name, :file_path, :thumbnail_path, :public_path, :public_thumbnail_path, :retain, :release, :to => :file
end
