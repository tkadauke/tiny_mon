class CheckRun < ActiveRecord::Base
  belongs_to :health_check
  belongs_to :account
  belongs_to :deployment
  has_many :comments, :dependent => :delete_all
  has_many :latest_comments, :class_name => 'Comment', :order => 'created_at DESC'
  
  serialize :log, Array
  
  before_create :set_account
  before_create :set_deployment
  after_update :update_health_check_status
  after_update :notify_subscribers
  
  scope :recent, order('check_runs.created_at DESC').limit(10)
  
  def duration
    (self.ended_at - self.started_at).to_f rescue 0.0
  end
  
  def self.from_param!(param)
    find(param)
  end
  
protected
  def set_account
    self.account_id = health_check.site.account_id
  end
  
  def set_deployment
    self.deployment = health_check.site.current_deployment
  end

  def update_health_check_status
    health_check.update_attribute(:status, self.status)
  end
  
  def notify_subscribers
    TinyMon::Notifier.new(self).notify! if self.status == 'failure' && health_check.enabled?
  end
end
