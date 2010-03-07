class Site < ActiveRecord::Base
  has_many :health_checks
end
