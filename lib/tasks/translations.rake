namespace :translations do
  desc 'Detect missing translations'
  task :missing => :environment do
    require 'ya2yaml'
    
    ignores = File.read(".i18nignore").split("\n").reject { |e| e.strip.blank? || e =~ /^#/ }.collect { |i| Regexp.new(i) } rescue []
    
    locale = (ENV['LOCALE'] || 'en').to_sym
    
    missing_ones = []
    view_regexps = [/[^\w]t\(\"(.*?)\".*?\)/, /[^\w]t\(\'(.*?)\'.*?\)/]
    code_regexps = [/I18n\.t\(\"(.*?)\".*?\)/, /I18n\.t\(\'(.*?)\'.*?\)/]
    
    Dir['app/views/**/*.erb', 'app/views/**/*.rhtml'].each do |filename|
      next if ignores.any? { |r| filename =~ r }
      
      content = File.read(filename)
      view_regexps.each do |view_regexp|
        content.scan(view_regexp) do |match|
          key = match.first
          next if key =~ /\#\{/
          if key =~ /^\./
            namespace = filename.gsub('app/views/', '').gsub('.html.erb', '').gsub('/', '.')
            key = (namespace + key).split('.').collect { |part| part.gsub(/^\_/, '') }.join('.')
          end
          missing_ones << key unless I18n.backend.send(:lookup, locale, key)
        end
      end
    end
    
    file_types = ['controllers', 'helpers', 'models']
    Dir[*file_types.collect { |t| "app/#{t}/**/*.rb" }].each do |filename|
      next if ignores.any? { |r| filename =~ r }
      
      content = File.read(filename)
      code_regexps.each do |code_regexp|
        content.scan(code_regexp) do |match|
          key = match.first
          next if key =~ /\#\{/
          missing_ones << key unless I18n.backend.send(:lookup, locale, key)
        end
      end
    end
    
    result = {}
    
    missing_ones.each do |key|
      current_hash = result
      parts = key.split(".")
      parts[0..-2].each do |part|
        current_hash[part] ||= {}
        current_hash = current_hash[part]
      end
      
      current_hash[parts.last] = ""
    end
    
    puts({ locale.to_s => result }.ya2yaml)
  end
end
