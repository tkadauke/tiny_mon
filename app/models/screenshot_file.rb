class ScreenshotFile
  PUBLIC_IMAGE_PATH = 'system'
  IMAGE_PATH = "#{Rails.root}/public/#{PUBLIC_IMAGE_PATH}"

  attr_accessor :checksum
  
  def initialize(checksum)
    @checksum = checksum
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
    "/#{PUBLIC_IMAGE_PATH}/#{file_name}.png"
  end
  
  def public_thumbnail_path
    "/#{PUBLIC_IMAGE_PATH}/#{file_name}-thumb.png"
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
  
  def self.store!(source, options = {})
    checksum = Digest::MD5.hexdigest(File.read(source))
    relative_file_path = checksum.sub(/^(..)(.*)$/, '\1/\2')
    absolute_file_path = File.join(IMAGE_PATH, relative_file_path)
    
    FileUtils.mkdir_p(File.dirname(absolute_file_path))
    FileUtils.mv source, absolute_file_path + '.png'
    
    if options[:thumbnail]
      system "convert -resize 180 #{absolute_file_path}.png #{absolute_file_path}-thumb.png"
    end
    
    new(checksum)
  end

protected
  def file_path_prefix
    "#{IMAGE_PATH}/#{file_name}"
  end

  def ref_counter_file
    "#{file_path_prefix}.count"
  end
end