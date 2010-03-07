module TinyMon
  class Config
    def self.method_missing(method)
      if config.has_key?(method.to_s)
        config[method.to_s]
      else
        super
      end
    end
  
    def self.config
      YAML.load(File.read("#{RAILS_ROOT}/config/config.yml"))
    end
  end
end
