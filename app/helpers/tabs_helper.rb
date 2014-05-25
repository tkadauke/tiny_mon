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
      @template.content_tag(:div, :class => 'nav-tabs-custom') do
        @template.content_tag(:ul, :class => 'nav nav-tabs') do
          @tabs.collect do |tab|
            @template.content_tag(:li, :class => tab[:name] == @options[:selected] ? 'active' : nil) do
              @template.link_to tab[:text], tab[:url]
            end
          end.join.html_safe
        end
      end
    end
  end
end
