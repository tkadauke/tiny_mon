module TabsHelper
  def tabs(options = {}, &block)
    yield builder = TabsBuilder.new(self, options)
    builder.build!
  end
  
  class TabsBuilder
    def initialize(template, options)
      @template = template
      @options = options
      @tabs = []
    end
    
    def tab(name, text, url)
      @tabs << { :name => name, :text => text, :url => url }
    end
    
    def build!
      @template.render "/shared/tabs", :tabs => @tabs, :options => @options
    end
  end
end
