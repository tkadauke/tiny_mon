require 'digest/md5'

module TinyMon
  class Renderer
    PUBLIC_IMAGE_PATH = 'system'
    IMAGE_PATH = "#{RAILS_ROOT}/public/#{PUBLIC_IMAGE_PATH}"
    
    def initialize(url, cookies)
      @url = url
      @cookies = cookies
    end
    
    def render!
      Dir.create_tmp_dir "renderer", "#{RAILS_ROOT}/tmp" do
        cookie_params = @cookies.collect { |cookie| %{--cookie "#{cookie.name}" "#{cookie.value}"} }.join(" ")
        system %{wkhtmltoimage #{cookie_params} "#{@url}" image.png}
        
        checksum = Digest::MD5.hexdigest(File.read("image.png"))
        relative_file_path = checksum.sub(/^(..)(.*)$/, '\1/\2')
        absolute_file_path = File.join(IMAGE_PATH, relative_file_path)
        
        FileUtils.mkdir_p(File.dirname(absolute_file_path))
        FileUtils.mv "image.png", absolute_file_path + '.png'
        
        system "convert -resize 180 #{absolute_file_path}.png #{absolute_file_path}-thumb.png"
        
        return checksum
      end
    end
  end
end
