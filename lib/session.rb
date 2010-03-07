class Session
  class PageNotFound < CheckFailed; end
  class ServerError < CheckFailed; end
  
  attr_accessor :response
  attr_accessor :cookie
  attr_accessor :log_entries
  
  def initialize(options)
    @options = options
    @log_entries = []
  end
  
  def log(message)
    log_entries << [Time.now, message]
  end
  
  def get(url)
    log "getting #{url}"
    uri = expand_url(url)
    response = http_object(uri.host, uri.scheme).get(uri.path, get_header)
    self.cookie = response.header['Set-Cookie'] if response.header['Set-Cookie']
    
    case response.code
    when /^30/
      get response.header['Location']
    when /404/
      raise PageNotFound, "Page #{url} not found"
    when /^50/
      raise ServerError, "Internal Server Error when loading #{url}"
    else
      self.response = response
    end
  end
  
protected
  def http_object(host, protocol)
    require 'net/https'
    
    if protocol == 'https'
      returning Net::HTTP.new(host, 443) do |http|
        http.use_ssl = true
      end
    else
      Net::HTTP.new(host)
    end
  end
  
  def expand_url(url)
    if url =~ /^http/
      URI.parse(url)
    else
      URI.join(@options[:base_url], url)
    end
  end
  
  def get_header
    header = {}
    header["Cookie"] = self.cookie if self.cookie
    header
  end
end
