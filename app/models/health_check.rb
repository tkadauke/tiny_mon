class HealthCheck < ActiveRecord::Base
  belongs_to :site
  belongs_to :health_check_import
  
  has_many :steps, :order => 'position ASC'
  has_many :check_runs, :dependent => :destroy
  has_many :recent_check_runs, :class_name => 'CheckRun', :order => 'created_at DESC', :limit => 50
  
  has_one :last_check_run, :class_name => 'CheckRun', :order => 'created_at DESC', :conditions => 'status is not null'
  
  has_many :comments, :through => :check_runs
  has_many :latest_comments, :through => :check_runs, :class_name => 'Comment', :source => 'comments', :order => 'comments.created_at DESC'
  
  named_scope :enabled, :conditions => { :enabled => true }
  
  validates_presence_of :site_id, :name, :interval
  
  attr_accessor :template, :template_data

  before_save :set_next_check_at, :if => :enabled_changed?
  before_validation :get_info_from_template
  
  has_permalink :name, :scope => :site_id
  
  def after_initialize
    self.template_data = HealthCheckTemplateData.new(self.template_data || {})
  end

  def self.upcoming(options = {})
    find :all, options.merge(:conditions => ["enabled and next_check_at > ?", Time.now], :order => 'next_check_at ASC')
  end
  
  def self.find_for_list(filter, find_options)
    with_search_scope(filter) do
      find(:all, find_options.merge(:include => {:site => :account}))
    end
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
    steps.find(:all).collect { |e| e.id == clone_id.to_i ? [e, e.clone] : e }.flatten
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
  
  def check!
    check_run = check_runs.create(:started_at => Time.now.to_f)
    update_attribute(:next_check_at, interval.minutes.from_now)
    do_check(check_run)
    check_run
  end
  
  def get_info_from_template
    return unless template && template_data && new_record?
    
    self.name = template.evaluate_name(template_data)
    self.description = template.evaluate_description(template_data)
    self.interval = template.interval
    self.steps = template.evaluate_steps(template_data)
  end
  
  def validate
    template.validate_health_check_data(self, template_data) if template && template_data && new_record?
  end
  
  def bulk_update(attributes)
    selections = attributes.inject({}) { |hash, pair| hash[pair.first] = pair.last if pair.first =~ /^bulk_update/; hash }.with_indifferent_access
    values = attributes.inject({}) { |hash, pair| hash[pair.first] = pair.last if pair.first !~ /^bulk_update/; hash }.with_indifferent_access
    
    values.reject! { |name, v| selections["bulk_update_#{name}"] != '1' }
    
    update_attributes(values)
  end
  
protected
  def do_check(check_run)
    runner = Runner.new(check_run.health_check)

    attrs = { :status => 'success' }

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

    check_run.update_attributes(attrs)
  ensure
    update_attributes(:last_checked_at => Time.now)
  end
  background_method :do_check

  def set_next_check_at
    self.next_check_at = 1.minute.from_now if enabled?
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
    
    with_scope :find => { :conditions => conditions } do
      yield
    end
  end
end
