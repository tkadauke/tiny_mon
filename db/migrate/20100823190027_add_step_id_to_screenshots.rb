class AddStepIdToScreenshots < ActiveRecord::Migration
  def self.up
    add_column :screenshots, :step_id, :integer
    
    add_index :screenshots, [:step_id, :created_at]
  end

  def self.down
    remove_column :screenshots, :step_id
  end
end
