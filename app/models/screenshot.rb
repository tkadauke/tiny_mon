class Screenshot < ActiveRecord::Base
  belongs_to :check_run
  
  validates_presence_of :checksum
  
  after_destroy :release
  after_create :retain
  
  def self.from_param!(param)
    find(param)
  end
  
  def file_name
    # use first two characters of checksum as directory
    checksum.sub(/^(..)(.*)$/, '\1/\2')
  end
  
  def file_path
    "#{file_path_prefix}.png"
  end
  
  def thumbnail_path
    "#{file_path_prefix}-thumb.png"
  end
  
  def public_path
    "/#{TinyMon::Renderer::PUBLIC_IMAGE_PATH}/#{file_name}.png"
  end
  
  def public_thumbnail_path
    "/#{TinyMon::Renderer::PUBLIC_IMAGE_PATH}/#{file_name}-thumb.png"
  end

protected
  def file_path_prefix
    "#{TinyMon::Renderer::IMAGE_PATH}/#{file_name}"
  end

  def ref_counter_file
    "#{file_path_prefix}.count"
  end
  
  def retain
    FileUtils.touch ref_counter_file
    
    count = File.read(ref_counter_file).to_i
    File.open(ref_counter_file, 'w') { |file| file.puts count + 1 }
  end
  
  def release
    FileUtils.touch ref_counter_file

    count = File.read(ref_counter_file).to_i
    if count <= 1
      FileUtils.rm_f file_path
      FileUtils.rm_f thumbnail_path
      FileUtils.rm_f ref_counter_file
    else
      File.open(ref_counter_file, 'w') { |file| file.puts count - 1 }
    end
  end
end
