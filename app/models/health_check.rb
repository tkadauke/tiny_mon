class HealthCheck < ActiveRecord::Base
  MINUTES_PER_DAY = 1440
  
  belongs_to :site
  belongs_to :health_check_import
  
  has_many :steps, :order => 'position ASC'
  has_many :check_runs, :dependent => :destroy
  has_many :recent_check_runs, :class_name => 'CheckRun', :order => 'created_at DESC', :limit => 50
  has_many :weather_relevant_check_runs, :class_name => 'CheckRun', :order => 'created_at DESC', :limit => 5
  
  has_one :last_check_run, :class_name => 'CheckRun', :order => 'created_at DESC', :conditions => 'status is not null'
  
  has_many :comments, :through => :check_runs
  has_many :latest_comments, :through => :check_runs, :class_name => 'Comment', :source => 'comments', :order => 'comments.created_at DESC'
  
  has_many :screenshots, :through => :check_runs
  has_many :latest_screenshots, :through => :check_runs, :class_name => 'Screenshot', :source => 'screenshots', :order => 'screenshots.created_at DESC'
  
  scope :enabled, where(:enabled => true)
  scope :upcoming, lambda { where("enabled and next_check_at > ?", Time.now).order('next_check_at ASC') }
  scope :due, lambda { enabled.where('next_check_at is not null and next_check_at < ?', Time.now) }
  scope :failed, enabled.where(:status => 'failure')
  
  validates_presence_of :site_id, :name, :interval
  validate :validate_template_data
  
  attr_accessor :template, :template_data

  before_save :set_next_check_at, :if => :schedule_next_check_now?
  before_validation :get_info_from_template
  
  after_save :update_account_check_runs_per_day
  after_destroy :update_account_check_runs_per_day
  
  has_permalink :name, :scope => :site_id
  
  after_initialize :set_template_data
  
  def set_template_data
    self.template_data = HealthCheckTemplateData.new(self.template_data || {})
  end

  def self.filter_for_list(filter, status)
    conditions = case status.to_s
    when 'success', 'failure'
      { :status => status.to_s, :enabled => true }
    when 'enabled'
      { :enabled => true }
    when 'disabled'
      { :enabled => false }
    end
    
    with_search_scope(filter).where(conditions).includes(:site => :account)
  end

  def self.due
    enabled.find :all, :conditions => ['next_check_at is not null and next_check_at < ?', Time.now]
  end
  
  # This method reenables health checks that got accidentally disabled, for example when
  # a worker died while performing the check, thus leaving it in a permanently disabled state
  def self.recover_zombies
    update_all ['next_check_at = ?', Time.now], ['next_check_at is null and last_checked_at < ?', 1.hour.ago]
  end

  def steps_with_clone(clone_id)
    steps.collect { |e| e.id == clone_id.to_i ? [e, e.clone] : e }.flatten
  end
  
  def self.intervals
    [1, 2, 3, 5, 10, 15, 20, 30, 60, 120, 180, 240, 360, 720, 1440]
  end
  
  def self.intervals_with_units
    self.intervals.collect { |interval| [interval >= 60 ? I18n.t('health_check.interval.hours', :count => interval / 60) : I18n.t('health_check.interval.minutes', :count => interval), interval] }
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
  
  def check!(user = nil)
    schedule_next_check(interval.minutes.from_now)
    
    if user || !site.account.over_maximum_check_runs_today?
      check_run = check_runs.create(:started_at => Time.now.to_f, :user => user)
      do_check(check_run)
      check_run
    end
  end
  
  def schedule_next_check(timestamp)
    update_attribute(:next_check_at, timestamp)
  end
  
  def get_info_from_template
    return unless template && template_data && new_record?
    
    self.name = template.evaluate_name(template_data)
    self.description = template.evaluate_description(template_data)
    self.interval = template.interval
    self.steps = template.evaluate_steps(template_data)
  end
  
  def validate_template_data
    template.validate_health_check_data(self, template_data) if template && template_data && new_record?
  end
  
  def bulk_update(attributes)
    selections = attributes.inject({}) { |hash, pair| hash[pair.first] = pair.last if pair.first =~ /^bulk_update/; hash }.with_indifferent_access
    values = attributes.inject({}) { |hash, pair| hash[pair.first] = pair.last if pair.first !~ /^bulk_update/; hash }.with_indifferent_access
    
    values.reject! { |name, v| selections["bulk_update_#{name}"] != '1' }
    
    update_attributes(values)
  end
  
  def check_runs_per_day
    (MINUTES_PER_DAY / self.interval).to_i
  end
  
  def update_status(status)
    update_attributes(:status => status, :weather => calculate_weather)
  end
  
  def as_json(options = {})
    attributes.merge(
      :site => site,
      :next_check_at_to_now => next_check_at.seconds_to_now,
      :last_checked_at_to_now => last_checked_at.seconds_to_now
    )
  end
  
protected
  def do_check(check_run)
    runner = Runner.new(check_run)

    attrs = { :status => 'success' }

    retry_times = 3
    begin
      runner.run!
    rescue Exception => e
      retry_times -= 1
      retry unless retry_times == 0

      attrs[:status] = 'failure'
      attrs[:error_message] = "#{e.class.name}: #{e.message}"
      attrs[:last_response] = runner.session.last_response
      puts e.backtrace
    end
    attrs[:ended_at] = Time.now.to_f
    attrs[:log] = runner.log_entries

    check_run.update_attributes(attrs)
  ensure
    update_attributes(:last_checked_at => Time.now)
  end
  background_method :do_check

  def schedule_next_check_now?
    enabled_changed? || interval_changed?
  end

  def set_next_check_at
    self.next_check_at = 1.minute.from_now if enabled?
  end
  
  def update_account_check_runs_per_day
    site.account.update_check_runs_per_day
  end

  def self.with_search_scope(filter, &block)
    conditions = if filter.empty?
      nil
    else
      # See activerecord/lib/active_record/associations.rb, line 1666
      #
      # For the SQL LIKE condition, we need to get rid of dots in the filter query, because ActiveRecord thinks
      # everything left of a dot is a referenced table, which results in SQL errors (few filter queries are actual
      # table names). This has the subtle consequence that a dot in the search field matches any character in the
      # SQL result set, whereas in the frontend only actual dots get highlighted. We replace dots with underscores,
      # which match a single character in SQL LIKE queries.
      sql_like = filter.query.gsub('.', '_')
      ['health_checks.name LIKE ? OR sites.name LIKE ?', "%#{sql_like}%", "%#{sql_like}%"]
    end
    
    where(conditions)
  end
  
  def calculate_weather
    last_check_runs = weather_relevant_check_runs
    fill_run_count = 5 - last_check_runs.size

    last_check_runs.select { |run| run.success? }.size + fill_run_count
  end
end
