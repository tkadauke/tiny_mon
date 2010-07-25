module I18n
  class << self
    def with_locale(new_locale, &block)
      old_locale = self.locale
      self.locale = new_locale
      
      yield
    ensure
      self.locale = old_locale
    end
  end
end
