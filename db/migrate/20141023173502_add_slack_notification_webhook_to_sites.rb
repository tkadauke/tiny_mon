class AddSlackNotificationToSites < ActiveRecord::Migration
  def change
    add_column :sites, :slack_webhook, :text
    remove_column :sites, :slack_team, :text
    remove_column :sites, :slack_token, :text
  end
end
