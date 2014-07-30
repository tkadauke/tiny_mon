namespace :scheduler do
  desc "TODO"
  task start: :environment do
    $run_from_rake = true
    Scheduler.run
  end
end
