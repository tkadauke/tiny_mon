# Port me to ActiveModel in Rails 3
class CheckRunFilter < TinyCore::TablelessModel
  column :start_date, :datetime
  column :end_date, :datetime
  
  validates_presence_of :start_date, :end_date
  validate :date_range_valid
  
  def date_range_valid
    errors.add(:start_date, 'Date range invalid') if start_date > end_date
  end
  
  def conditions
    ['check_runs.created_at between (?) and (?)', start_date, end_date] if valid?
  end
end
