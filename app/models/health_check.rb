class HealthCheck < ActiveRecord::Base
  belongs_to :site
  has_many :steps
  has_many :check_runs
end
