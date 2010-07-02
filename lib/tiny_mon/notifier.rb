module TinyMon
  class Notifier
    def initialize(check_run)
      @check_run = check_run
    end
    
    def notify!
      @check_run.health_check.subscribers.each do |user|
        Notification::Email.new.send("deliver_#{@check_run.status}", @check_run, user) if user.config.email_enabled
        Notification::Prowl.new.send("deliver_#{@check_run.status}", @check_run, user) if user.config.prowl_enabled
      end
    end
  end
end
