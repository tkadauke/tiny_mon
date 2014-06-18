require 'lhm'

class AddAlwaysSendNotificationToHealthChecks < ActiveRecord::Migration
  def self.up
    add_column :health_checks, :always_send_notification, :boolean
  end

  def self.down
    remove_column :health_checks, :always_send_notification
  end
end
