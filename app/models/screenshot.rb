class Screenshot < ActiveRecord::Base
  belongs_to :check_run
  
  after_destroy :release
  after_create :retain
  
  def file_name
    # use first two characters of checksum as directory
    checksum.sub(/^(..)(.*)$/, '\1/\2')
  end
  
  def file_path
    "#{RAILS_ROOT}/public/system/#{file_name}"
  end

protected
  def ref_counter_file
    "#{file_path}.count"
  end
  
  def retain
    count = File.read(ref_counter_file).to_i
    File.open(ref_counter_file) { |file| file.puts count + 1 }
  end
  
  def release
    count = File.read(ref_counter_file).to_i
    if count <= 1
      FileUtils.rm_f file_path
      FileUtils.rm_f ref_counter_file
    else
      File.open(ref_counter_file) { |file| file.puts count - 1 }
    end
  end
end
