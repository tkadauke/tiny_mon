module Webrat
  class Form < Element #:nodoc:
    def params
      all_params = OrderedHash.new

      fields.each do |field|
        next if field.to_param.nil?
        merge(all_params, field.to_param)
      end

      all_params
    end
  end
end
