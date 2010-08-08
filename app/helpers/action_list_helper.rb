module ActionListHelper
  def action_list(&block)
    yield builder = ActionListBuilder.new(self)
    builder.build!
  end
  
  class ActionListBuilder
    def initialize(template)
      @template = template
      @items = []
    end
    
    def method_missing(method, *args)
      if @template.respond_to?(method)
        @items << @template.send(method, *args)
      else
        super
      end
    end
    
    def build!
      @items.join(' | ').html_safe
    end
  end
end