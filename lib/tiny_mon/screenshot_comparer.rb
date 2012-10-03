module TinyMon
  class ScreenshotComparer
    def initialize(first, second)
      @first, @second = first, second
    end
    
    def compare!
      Dir.create_tmp_dir "comparer", "#{Rails.root}/tmp" do
        system %{compare #{@first.file_path} #{@second.file_path} diff.png}
        system %{pngcrush diff.png}
        
        checksum = ScreenshotFile.store!("diff.png", :thumbnail => true).checksum
        
        ScreenshotComparison.new(:checksum => checksum, :first_screenshot => @first, :second_screenshot => @second)
      end
    end
  end
end
