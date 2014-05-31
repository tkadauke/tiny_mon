class CheckRun < ActiveRecord::Base
  belongs_to :health_check
  belongs_to :account
  belongs_to :deployment
  belongs_to :user
  has_many :comments, :dependent => :delete_all
  has_many :latest_comments, lambda { order('created_at DESC') }, :class_name => 'Comment'
  has_many :screenshots, :dependent => :destroy
  has_many :screenshot_comparisons, :dependent => :destroy
  
  serialize :log, Array
  
  before_create :set_account
  before_create :set_deployment
  after_update :update_health_check_status
  after_update :notify_subscribers, :if => :send_notification?
  before_save :truncate_values
  
  scope :recent, lambda { order('check_runs.created_at DESC').limit(10) }
  scope :today, lambda { where(['created_at > ?', Date.today.to_time]) }
  scope :scheduled, lambda { where('user_id is null') }
  
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
  
  def as_json(options = {})
    attributes.merge(
      :duration => duration,
      :health_check => health_check,
      :created_at_to_now => created_at.try(:seconds_to_now)
    )
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
    TinyMon::Notifier.new(self).notify!
  end
  
  def send_notification?
    user.blank? && health_check.enabled? && self.status != previous_check_run.try(:status)
  end
  
  def previous_check_run
    runs = health_check.check_runs.where('status is not null').order('id desc').first(2)
    runs.last if runs.size == 2
  end

  def truncate_values
    self.last_response = self.last_response.truncate(55000) if self.last_response && self.last_response.length > 55000
    self.error_message = self.error_message.truncate(230) if self.error_message && self.error_message.length > 230
  end
end
