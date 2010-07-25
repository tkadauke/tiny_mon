module TinyMon
  class CommentNotifier
    def initialize(comment)
      @comment = comment
    end
    
    def notify!
      @comment.check_run.health_check.subscribers.each do |user|
        I18n.with_locale user.config.language do
          CommentMailer.deliver_comment(@comment, user) if user.config.notify_comments && user != @comment.user
        end
      end
    end
  end
end
