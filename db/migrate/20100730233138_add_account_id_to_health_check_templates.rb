class AddAccountIdToHealthCheckTemplates < ActiveRecord::Migration
  def self.up
    add_column :health_check_templates, :account_id, :integer
    
    add_index :health_check_templates, :account_id
  end

  def self.down
    remove_column :health_check_templates, :account_id
  end
end
