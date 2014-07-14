require 'slack-notifier'

module TinyMon
  class Notifier
    def initialize(check_run)
      @check_run = check_run
    end
    
    def notify!
      @check_run.health_check.subscribers.each do |user|
        I18n.with_locale user.config.language do
          Notification::Email.new.send("deliver_#{@check_run.status}", @check_run, user) if user.config.email_enabled
          Notification::Prowl.new.send("deliver_#{@check_run.status}", @check_run, user) if user.config.prowl_enabled
        end
      end
      #handle slack
      if @check_run.health_check.site.slack_enabled && !@check_run.health_check.site.slack_team.empty? && !@check_run.health_check.site.slack_token.empty?
        notifier = Slack::Notifier.new @check_run.health_check.site.slack_team, @check_run.health_check.site.slack_token
        notifier.username = 'TinyMon'
        if @check_run.status == 'success'
          color = 'good'
        elsif @check_run.status == 'failure'
          color = 'danger'
        else
          color = '3c8dbc'
        end
        msg_txt = @check_run.health_check.name + ' ' + @check_run.status
        msg_link_txt = '<http://' + TinyMon::Config.host + Rails.application.routes.url_helpers.account_site_health_check_check_run_path(@check_run.health_check.site.account, @check_run.health_check.site, @check_run.health_check, @check_run, :locale => 'en')+'|Click here for more info>'

        a_ok_note = {
            fallback: msg_txt, text: msg_txt + " " + msg_link_txt, color: color
        }
        notifier.ping '', attachments: [a_ok_note]
      end
    end
  end
end
