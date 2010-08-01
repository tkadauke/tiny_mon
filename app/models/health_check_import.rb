class HealthCheckImport < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  belongs_to :account
  belongs_to :health_check_template
  
  has_many :health_checks, :dependent => :destroy
  
  after_create :import!
  
  validates_presence_of :user_id, :site_id, :account_id, :health_check_template_id, :csv_data
  
  def rows
    @rows ||= FasterCSV.parse(csv_data)
  end
  
  def headers
    health_check_template.variables
  end
  
  def import!
    rows.each do |row|
      site.health_checks.create(:template => health_check_template, :template_data => row_to_template_data(row), :health_check_import => self)
    end
  end
  
private
  def row_to_template_data(row)
    data_hash = {}
    row.each_with_index do |cell, i|
      data_hash[headers[i].name] = cell
    end
    
    data_hash
  end
end
