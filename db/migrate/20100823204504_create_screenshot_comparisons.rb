class CreateScreenshotComparisons < ActiveRecord::Migration
  def self.up
    create_table :screenshot_comparisons do |t|
      t.integer :check_run_id
      t.integer :first_screenshot_id
      t.integer :second_screenshot_id
      t.string :checksum
      t.float :distance
      t.timestamps
    end
  end

  def self.down
    drop_table :screenshot_comparisons
  end
end
