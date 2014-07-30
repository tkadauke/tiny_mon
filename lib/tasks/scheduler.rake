namespace :scheduler do
  desc "TODO"
  task start: :environment do
    Scheduler.run
  end

end
