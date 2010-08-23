class CheckRun < ActiveRecord::Base
  belongs_to :health_check
  belongs_to :account
  belongs_to :deployment
  belongs_to :user
  has_many :comments, :dependent => :delete_all
  has_many :latest_comments, :class_name => 'Comment', :order => 'created_at DESC'
  has_many :screenshots, :dependent => :destroy
  has_many :screenshot_comparisons, :dependent => :destroy
  
  serialize :log, Array
  
  before_create :set_account
  before_create :set_deployment
  after_update :update_health_check_status
  after_update :notify_subscribers
  
  named_scope :recent, :order => 'check_runs.created_at DESC', :limit => 10
  named_scope :today, lambda { { :conditions => ['created_at > ?', Date.today.to_time] } }
  named_scope :scheduled, :conditions => 'user_id is null'
  
  def duration
    (self.ended_at - self.started_at).to_f rescue 0.0
  end
  
  def self.from_param!(param)
    find(param)
  end
  
  def success?
    status == 'success'
  end
  
  def first_in_deployment?
    if deployment
      deployment.check_runs.count <= 1
    else
      health_check.check_runs.count <= 1
    end
  end
  
protected
  def set_account
    self.account_id = health_check.site.account_id
  end
  
  def set_deployment
    self.deployment = health_check.site.current_deployment
  end

  def update_health_check_status
    health_check.update_status(self.status)
  end
  
  def notify_subscribers
    TinyMon::Notifier.new(self).notify! if user.blank? && self.status == 'failure' && health_check.enabled?
  end
end
