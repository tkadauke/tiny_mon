module TinyMon
  module Version
    extend self
    
    def version
      '0.3.0'
    end
    
    def build
      @build ||= Dir.chdir Rails.root do
        begin
          revision = 'git rev-parse HEAD'
        rescue Exception=>e
          revision = 'CI build'
        end
        revision.blank? ? 'unknown' : revision
      end
    end
  end
end
