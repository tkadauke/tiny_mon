class HealthCheck < ActiveRecord::Base
  belongs_to :site
  has_many :steps, :order => 'position ASC'
  has_many :check_runs
  has_many :recent_check_runs, :class_name => 'CheckRun', :order => 'created_at DESC', :limit => 50
  
  has_one :last_check_run, :class_name => 'CheckRun', :order => 'created_at DESC'
  
  has_many :comments, :through => :check_runs
  has_many :latest_comments, :through => :check_runs, :class_name => 'Comment', :source => 'comments'
  
  named_scope :enabled, :conditions => { :enabled => true }
  
  has_permalink :name, :scope => :site_id
  
  validates_presence_of :site_id, :name, :interval
  
  before_save :set_next_check_at, :if => :enabled_changed?
  
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
    check_run = check_runs.create(:started_at => Time.now.to_f)
    do_check(check_run)
    check_run
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
    update_attributes(:last_checked_at => Time.now, :next_check_at => interval.minutes.from_now)
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
