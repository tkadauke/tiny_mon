class CheckRunFilter
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_accessor :start_date
  attr_accessor :end_date
  
  validates_presence_of :start_date, :end_date
  validate :date_range_valid
  
  def initialize(attributes = {})
    return if attributes.nil?
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def date_range_valid
    errors.add(:start_date, 'Date range invalid') if start_date && end_date && start_date > end_date
  end
  
  def conditions
    ['check_runs.created_at between (?) and (?)', start_date, end_date] if valid?
  end

  def persisted?
    false
  end
end
