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
      @template.content_tag(:ul, :class => 'tabs') do
        @tabs.collect do |tab|
          if tab[:name] == @options[:selected]
            @template.content_tag(:li, :class => 'selected') do
              @template.content_tag(:span) { tab[:text] }
            end
          else
            @template.content_tag(:li) do
              @template.link_to tab[:text], tab[:url]
            end
          end
        end.join.html_safe
      end
    end
  end
end
