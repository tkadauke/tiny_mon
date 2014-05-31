module HasProperties
  module SingletonMethods
    def has_properties(options = {})
      default_options = { :in => :data }
      options = default_options.merge(options)
      
      cattr_accessor :property_field
      self.property_field = options[:in]
      class_attribute :properties
      self.properties = {}
      
      serialize self.property_field, Hash

      extend  ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    def property(name, type)
      self.properties = self.properties.merge(name => type)

      define_method name do
        convert_property(property_hash[name.to_s], type)
      end
      
      define_method "#{name}=" do |value|
        property_hash[name.to_s] = convert_property(value, type)
      end
    end
  end
  
  module InstanceMethods
    def property_hash
      send("#{self.class.property_field}=", {}) unless send(self.class.property_field)
      send(self.class.property_field)
    end
    
    def convert_property(value, type)
      case type.to_sym
      when :string
        value.to_s
      when :integer
        value.to_i
      when :boolean
        value.to_bool
      end
    end
  end
  
  def self.included(receiver)
    receiver.extend         SingletonMethods
    receiver.send :include, InstanceMethods
  end
end
