class SearchFilter
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :query
  
  def initialize(attributes = {})
    return if attributes.nil?
    
    @query = attributes[:query]
  end
  
  def empty?
    query.blank?
  end
  
  def id
    1
  end
  
  def persisted?
    false
  end
end
