class AddDeploymentTokenToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :deployment_token, :string
    
    add_index :sites, :deployment_token
    
    Site.reset_column_information
    
    Site.all.each do |site|
      site.send :set_deployment_token
      site.save
    end
  end

  def self.down
    remove_column :sites, :deployment_token
  end
end
