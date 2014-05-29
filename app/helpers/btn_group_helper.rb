module BtnGroupHelper
  def btn_group(text, url, options = {}, &block)
    yield builder = BtnGroupBuilder.new(self, text, url, options)
    builder.build!
  end

  class BtnGroupBuilder
    def initialize(template, text, url, options)
      @template = template
      @text = text
      @url = url
      @options = options
      @items = []
    end

    def link_to(text, url, options = {})
      @items << {
        :text => text,
        :url => url,
        :options => options
      }
    end

    def build!
      @template.render "/shared/#{@options.delete(:template) || 'btn_group'}", :text => @text, :url => @url, :options => @options, :items => @items
    end
  end
end
