class CheckRunFilter
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations
  extend DateWriter

  attr_accessor :start_date
  attr_accessor :end_date
  attr_accessor :health_check_id

  date_writer :start_date, :end_date

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
    if health_check_id && valid?
      ['check_runs.created_at between (?) and (?) and check_runs.health_check_id = (?)', start_date, end_date, health_check_id]
    elsif health_check_id
      ['check_runs.health_check_id = (?)', health_check_id]
    elsif valid?
      ['check_runs.created_at between (?) and (?)', start_date, end_date]
    end
  end

  def persisted?
    false
  end
end
