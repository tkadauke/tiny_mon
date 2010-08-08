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
      YAML.load(File.read("#{Rails.root}/config/config.yml"))
    end
  end
end
