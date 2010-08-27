class CommentMailer < ActionMailer::Base
  def comment(comment, user)
    subject I18n.t("comment_mailer.comment.subject", :health_check => comment.check_run.health_check.name, :title => comment.title)
    recipients user.email
    from "TinyMon <#{TinyCore::Config.email_sender_address}>"
    body :comment => comment
  end
end
