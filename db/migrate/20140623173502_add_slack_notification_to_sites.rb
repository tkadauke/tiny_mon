class AddSlackNotificationToSites < ActiveRecord::Migration
  def change
    add_column :sites, :slack_enabled, :boolean
    add_column :sites, :slack_team, :text
    add_column :sites, :slack_token, :text
  end
end
