class User
  class Configuration
    class Option
      attr_reader :key, :name, :description, :type, :default, :values
      
      def initialize(key, hash)
        @key = key
        ['name', 'description', 'type', 'default', 'values'].each do |var|
          instance_variable_set(:"@#{var}", hash[var])
        end
      end
    end
    
    def initialize(user)
      @user_id = user.id
    end
    
    def config
      @config ||= YAML.load(ERB.new(File.read(config_file_name)).result)
    end
  
    def reload!
      @config = nil
    end
  
    def options
      keys.collect do |key|
        option(key)
      end
    end
  
    def option(key)
      Option.new(key.to_s, find_option(key.to_s))
    end
  
    def keys
      config.collect { |opt| opt.keys.first }
    end
  
    def get(key)
      option = option(key)
      db_option = get_config_option(key)
      if db_option
        type_cast(YAML.load(db_option.value), option.type)
      else
        option.default
      end
    end
  
    def set(key, value)
      option = option(key)
      set_config_option(key, type_cast(value, option.type))
    end
  
    def update_attributes(attributes = {})
      attributes.each do |key, value|
        set(key, value)
      end
      true
    end
  
    def method_missing(method)
      if find_option(method.to_s)
        get(method.to_s)
      else
        super
      end
    end

  private
    def config_file_name
      "#{Rails.root}/config/options.yml"
    end
  
    def get_config_option(key)
      ConfigOption.find_by_user_id_and_key(@user_id, key)
    end
  
    def set_config_option(key, value)
      db_option = ConfigOption.find_or_create_by_user_id_and_key(@user_id, key.to_s)
      db_option.update_attribute(:value, value.to_yaml)
    end
  
    def find_option(key)
      config.find { |opt| opt.keys.first == key }.values.first rescue nil
    end
  
    def type_cast(value, type)
      case type
      when 'Integer' then value.to_i
      when 'Boolean'
        if value.respond_to?(:to_i)
          value.to_i == 1
        else
          value
        end
      else
        value
      end
    end
  end
end
