class AddLastResponseToCheckRuns < TableMigration
  migrates :check_runs

  change_table do |t|
    t.text :last_response
  end
end
