class ConfigOption < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :key
end
