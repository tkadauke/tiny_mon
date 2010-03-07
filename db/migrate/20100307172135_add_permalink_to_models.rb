class AddPermalinkToModels < ActiveRecord::Migration
  def self.up
    add_column :sites, :permalink, :string
    add_column :health_checks, :permalink, :string
  end

  def self.down
    remove_column :health_checks, :permalink
    remove_column :sites, :permalink
  end
end
