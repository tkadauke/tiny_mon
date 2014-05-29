module DateWriter
  def date_writer(*writers)
    writers.each do |writer|
      define_method "#{writer}(1i)=" do |value|
        send("#{writer}=", Date.new) unless send(writer)

        orig = send(writer)
        send("#{writer}=", Date.new(value.to_i, orig.month, orig.day))
      end

      define_method "#{writer}(2i)=" do |value|
        send("#{writer}=", Date.new) unless send(writer)

        orig = send(writer)
        send("#{writer}=", Date.new(orig.year, value.to_i, orig.day))
      end

      define_method "#{writer}(3i)=" do |value|
        send("#{writer}=", Date.new) unless send(writer)

        orig = send(writer)
        send("#{writer}=", Date.new(orig.year, orig.month, value.to_i))
      end
    end
  end
end
