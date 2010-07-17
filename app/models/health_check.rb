class HealthCheck < ActiveRecord::Base
  belongs_to :site
  has_many :steps, :order => 'position ASC'
  has_many :check_runs
  has_many :recent_check_runs, :class_name => 'CheckRun', :order => 'created_at DESC', :limit => 50
  
  has_one :last_check_run, :class_name => 'CheckRun', :order => 'created_at DESC'
  
  named_scope :enabled, :conditions => { :enabled => true }
  
  before_save :set_next_check_at, :if => :enabled_changed?
  
  def self.due
    enabled.find :all, :conditions => ['next_check_at is not null and next_check_at < ?', Time.now]
  end
  
  # This method reenables health checks that got accidentally disabled, for example when
  # a worker died while performing the check, thus leaving it in a permanently disabled state
  def self.recover_zombies
    update_all ['next_check_at = ?', Time.now], ['next_check_at is null and last_checked_at < ?', 1.hour.ago]
  end

  has_permalink :name, :scope => :site_id
  
  validates_presence_of :site_id, :name
  
  def steps_with_clone(clone_id)
    steps.find(:all).collect { |e| e.id == clone_id.to_i ? [e, e.clone] : e }.flatten
  end
  
  def self.intervals
    [1, 2, 3, 5, 10, 15, 20, 30, 60]
  end
  
  def to_param
    permalink
  end
  
  def self.from_param!(param)
    find_by_permalink!(param)
  end
  
  def subscribers
    site.account.users
  end
  
  def prepare_check!
    update_attribute(:next_check_at, nil)
  end
  
  def check!
    runner = Runner.new(self)
    attrs = { :started_at => Time.now.to_f, :status => 'success' }

    retry_times = 3
    begin
      runner.run!
    rescue Exception => e
      retry_times -= 1
      retry unless retry_times == 0

      attrs[:status] = 'failure'
      attrs[:error_message] = "#{e.class.name}: #{e.message}"
    end
    attrs[:ended_at] = Time.now.to_f
    attrs[:log] = runner.log_entries

    check_runs.create(attrs)
  ensure
    update_attributes(:last_checked_at => Time.now, :next_check_at => interval.minutes.from_now)
  end
  background_method :check!
  
protected
  def set_next_check_at
    self.next_check_at = 1.minute.from_now if enabled?
  end
end
