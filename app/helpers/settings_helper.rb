module SettingsHelper
  def translate_if_possible(text_or_hash)
    if text_or_hash.is_a?(Hash)
      text_or_hash[I18n.locale.to_s]
    else
      text_or_hash
    end
  end
end
