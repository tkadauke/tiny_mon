module Webrat
  class Link < Element #:nodoc:
  protected
    def absolute_href
      if href =~ /^\?/
        "#{@session.current_url}#{href}"
      elsif href =~ %r{^https?://}
        href
      elsif href =~ /^\//
        href
      else
        parts = @session.current_url.to_s.split(/\//)
        if parts.size == 3
          # http: / / www.domain.com
          "#{@session.current_url.to_s.gsub(/\/$/, '')}/#{href}"
        else
          # http: / / www.domain.com / something
          "#{parts[0..-2].join('/').gsub(/\/$/, '')}/#{href}"
        end
      end
    end
  end
end
