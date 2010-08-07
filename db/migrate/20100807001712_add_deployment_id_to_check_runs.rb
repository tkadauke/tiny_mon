class AddDeploymentIdToCheckRuns < TableMigration
  migrates :check_runs

  change_table do |t|
    t.integer :deployment_id
    t.index   :deployment_id
  end
end
