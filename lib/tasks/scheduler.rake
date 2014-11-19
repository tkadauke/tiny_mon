namespace :scheduler do
  desc "This could be used to run the worker via rake"
  task start: :environment do
    $run_from_rake = true
    Scheduler.run
  end
end
