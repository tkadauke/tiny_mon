module TinyMon
  module Notification
    class Email < Base
      def deliver_success(check_run, user)
        
      end
      
      def deliver_failure(check_run, user)
        CheckRunMailer.deliver_failure(check_run, user)
      end
    end
  end
end
