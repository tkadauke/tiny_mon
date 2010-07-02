module TinyMon
  module Notification
    class Base
      def deliver_success(check_run, user)
        raise NotImplementedError
      end
    
      def deliver_failure(check_run, user)
        raise NotImplementedError
      end
    end
  end
end
