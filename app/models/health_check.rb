class HealthCheck < ActiveRecord::Base
  belongs_to :site
  has_many :steps
end
