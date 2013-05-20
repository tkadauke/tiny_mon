class Object
  def to_bool
    true
  end
end

class NilClass
  def to_bool
    false
  end
end

class FalseClass
  def to_bool
    false
  end
end

class Numeric
  def to_bool
    self != 0
  end
end

class String
  def to_bool
    self == '1' || downcase == 'true'
  end
end
