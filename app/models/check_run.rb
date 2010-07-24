class CheckRun < ActiveRecord::Base
  belongs_to :health_check
  belongs_to :account
  has_many :comments
  has_many :latest_comments, :class_name => 'Comment', :order => 'created_at DESC'
  
  serialize :log, Array
  
  before_create :set_account
  after_update :update_health_check_status
  after_update :notify_subscribers
  
  named_scope :recent, :order => 'check_runs.created_at DESC', :limit => 10
  
  def duration
    (self.ended_at - self.started_at).to_f
  end
  
  def self.from_param!(param)
    find(param)
  end
  
protected
  def set_account
    self.account_id = health_check.site.account_id
  end

  def update_health_check_status
    health_check.update_attribute(:status, self.status)
  end
  
  def notify_subscribers
    TinyMon::Notifier.new(self).notify! if self.status == 'failure' && health_check.enabled?
  end
end
