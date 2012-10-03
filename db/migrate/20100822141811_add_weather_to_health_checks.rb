class AddWeatherToHealthChecks < ActiveRecord::Migration
  def self.up
    add_column :health_checks, :weather, :integer
    
    HealthCheck.reset_column_information
    HealthCheck.all.each do |health_check|
      health_check.update_attribute(:weather, health_check.send(:calculate_weather))
    end
  end

  def self.down
    remove_column :health_checks, :weather
  end
end
