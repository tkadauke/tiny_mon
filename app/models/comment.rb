class Comment < ActiveRecord::Base
  belongs_to :check_run
  belongs_to :user
  belongs_to :account
  
  before_save :set_account_id
  
  validates_presence_of :text
  
  after_create :notify_subscribers
  
  scope :visible_to, lambda { |user| where('account_id in (?)', user.accounts.map(&:id)) }
  
protected
  def notify_subscribers
    TinyMon::CommentNotifier.new(self).notify!
  end
  background_method :notify_subscribers
  
  def set_account_id
    self.account_id = check_run.account_id
  end
end
