module Role::Base
  module ClassMethods
    def allow(*things)
      things.each do |thing|
        define_method "can_#{thing}?" do
          true
        end
      end
    end
  end
  
  def method_missing(method, *args)
    if method.to_s =~ /^can_.*\?$/
      false
    else
      super
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
end
