class AddIndexOnCheckRuns < TableMigration
  migrates :check_runs

  change_table do |t|
    t.index [:health_check_id, :created_at]
  end
end
