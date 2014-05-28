require 'digest/md5'

module TinyMon
  class Renderer
    def initialize(url, cookies, stylesheet)
      @url = url
      @cookies = cookies
      @stylesheet = stylesheet
    end
    
    def render!
      Dir.create_tmp_dir "renderer", "#{Rails.root}/tmp" do
        cookie_params = @cookies.collect { |cookie| %{--cookie "#{cookie.name}" "#{cookie.value}"} }.join(" ")
        
        stylesheet_params = if @stylesheet
          File.open('stylesheet.css', 'w') { |file| file.puts @stylesheet }
          %{--user-style-sheet stylesheet.css}
        else
          ""
        end
        
        system %{wkhtmltoimage #{cookie_params} --width 1280 #{stylesheet_params} "#{@url}" screenshot.png}
        system %{pngcrush screenshot.png crushed.png}
        
        file = ScreenshotFile.store!("crushed.png", :thumbnail => true)
        
        Screenshot.new(:checksum => file.checksum)
      end
    end
  end
end
