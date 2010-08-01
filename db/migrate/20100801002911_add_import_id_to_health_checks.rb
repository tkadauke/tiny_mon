class AddImportIdToHealthChecks < ActiveRecord::Migration
  def self.up
    add_column :health_checks, :health_check_import_id, :integer
  end

  def self.down
    remove_column :health_checks, :health_check_import_id
  end
end
