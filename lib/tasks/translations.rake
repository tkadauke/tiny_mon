module Translations
  class Scanner
    def scan(&block)
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
            yield key
          end
        end
      end

      file_types = ['controllers', 'helpers', 'models']
      Dir["lib/**/*.rb", *file_types.collect { |t| "app/#{t}/**/*.rb" }].each do |filename|
        next if ignores.any? { |r| filename =~ r }

        content = File.read(filename)
        code_regexps.each do |code_regexp|
          content.scan(code_regexp) do |match|
            key = match.first
            next if key =~ /\#\{/
            yield key
          end
        end
      end
    end
    
  private
    def ignores
      @ignores ||= File.read(".i18nignore").split("\n").reject { |e| e.strip.blank? || e =~ /^#/ }.collect { |i| Regexp.new(i) } rescue []
    end
  end
  
  def self.extract_i18n_keys(prefix, object)
    case object
    when Hash
      return prefix if object.keys.include?(:one) && object.keys.include?(:other)
      object.collect do |key, value|
        extract_i18n_keys([prefix, key].join('.'), value)
      end.flatten.compact
    when String
      prefix
    end
  end
end

namespace :translations do
  task :setup => :environment do
    require 'ya2yaml'

    @locale = (ENV['LOCALE'] || 'en').to_sym
  end
  
  desc 'Detect missing translations'
  task :missing => :setup do
    missing_ones = []
    
    scanner = Translations::Scanner.new.scan do |key|
      missing_ones << key unless I18n.backend.send(:lookup, @locale, key)
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
    
    puts({ @locale.to_s => result }.ya2yaml)
  end
  
  task :unused => :setup do
    ignore_keys = ['account.role', 'activerecord', 'authlogic', 'breadcrumb', 'date.formats', 'datetime', 'health_check_template.condition',
                   'health_check_template.variable.type', 'number', 'status', 'step', 'support.array', 'time']
    ignore_keys_regexps = ignore_keys.collect { |key| Regexp.new(Regexp.escape("#{@locale}.#{key}"))  }

    used_ones = []

    scanner = Translations::Scanner.new.scan do |key|
      used_ones << [@locale, key].join('.')
    end
    
    defined_ones = Translations.extract_i18n_keys(@locale.to_s, I18n.backend.send(:lookup, @locale, ''))
    
    unused = (defined_ones - used_ones).reject { |key| ignore_keys_regexps.any? { |rx| rx =~ key } }.sort
    
    puts unused
  end
end
