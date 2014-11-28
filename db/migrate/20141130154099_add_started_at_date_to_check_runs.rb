class AddStartedAtDateToCheckRuns < ActiveRecord::Migration
  def change
    add_column :check_runs, :started_at_date, :datetime
    add_column :check_runs, :ended_at_date, :datetime
  end
end
