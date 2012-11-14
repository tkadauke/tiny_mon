module TinyMon
  module Notification
    class Email < Base
      def deliver_success(check_run, user)
        CheckRunMailer.success(check_run, user).deliver
      end
      
      def deliver_failure(check_run, user)
        CheckRunMailer.failure(check_run, user).deliver
      end
    end
  end
end
