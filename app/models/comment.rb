class Comment < ActiveRecord::Base
  belongs_to :check_run
  belongs_to :user
  
  before_save :set_account_id
  
  validates_presence_of :text
  
  after_create :notify_subscribers
  
protected
  def notify_subscribers
    TinyMon::CommentNotifier.new(self).notify!
  end
  background_method :notify_subscribers
  
  def set_account_id
    self.account_id = check_run.account_id
  end
end
