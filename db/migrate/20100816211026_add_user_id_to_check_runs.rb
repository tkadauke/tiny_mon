class AddUserIdToCheckRuns < TableMigration
  migrates :check_runs

  change_table do |t|
    t.integer :user_id
  end
end
