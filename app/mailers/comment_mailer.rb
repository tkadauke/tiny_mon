class CommentMailer < ActionMailer::Base
  default :from => ENV['SMTP_SENDER'] ? ENV['SMTP_SENDER'] : 'TinyMon Notification <notifications@tinymon.org>'

  def comment(comment, user)
    @comment = comment
    
    mail :to => user.email, :subject => I18n.t("comment_mailer.comment.subject", :health_check => comment.check_run.health_check.name, :title => comment.title)
  end
end
