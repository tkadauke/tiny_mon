module TinyMon
  module Notification
    class Prowl < Base
      def deliver_success(check_run, user)
        if prowl_available?
          ::Prowl.add({
            :application => "TinyMon",
            :apikey => user.config.prowl_api_key,
            :event => I18n.t('prowl.event.success'),
            :description => I18n.t('prowl.description.success', :health_check => check_run.health_check.name, :site => check_run.health_check.site.name)
          })
        end
      rescue SocketError
        raise "Could not connect to Prowl"
      end
    
      def deliver_failure(check_run, user)
        if prowl_available?
          ::Prowl.add({
            :application => "TinyMon",
            :apikey => user.config.prowl_api_key,
            :event => I18n.t('prowl.event.failure'),
            :description => I18n.t('prowl.description.failure', :health_check => check_run.health_check.name, :site => check_run.health_check.site.name)
          })
        end
      rescue SocketError
        raise "Could not connect to Prowl"
      end
    
    protected
      def prowl_available?
        @prowl_available ||= load_prowl
      end
      
      def load_prowl
        require 'prowl'
        true
      rescue LoadError
        false
      end
    end
  end
end
