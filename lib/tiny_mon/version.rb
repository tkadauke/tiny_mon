module TinyMon
  module Version
    extend self
    
    def version
      '0.0.1'
    end
    
    def build
      @build ||= Dir.chdir Rails.root do
        revision = `git rev-parse HEAD`
        revision.blank? ? 'unknown' : revision
      end
    end
  end
end
