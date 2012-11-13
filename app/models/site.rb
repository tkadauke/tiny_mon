class Site < ActiveRecord::Base
  belongs_to :account
  has_many :health_checks, :dependent => :destroy
  has_many :health_check_imports, :dependent => :destroy
  has_many :deployments
  
  has_permalink :name
  
  validates_presence_of :name, :url
  
  before_save :set_deployment_token
  
  def to_param
    permalink
  end
  
  def current_deployment
    deployments.last
  end
  
  def all_checks_successful?
    health_checks.failed.count == 0
  end
  
  def status
    if health_checks.count > 0
      all_checks_successful? ? 'success' : 'failure'
    else
      'offline'
    end
  end
  
  def self.from_param!(param)
    find_by_permalink!(param)
  end
  
  def self.find_for_list(filter)
    with_search_scope(filter).includes(:account).order('sites.name ASC')
  end
  
  def as_json(options = {})
    attributes.merge(:status => status)
  end

protected
  def self.with_search_scope(filter, &block)
    conditions = filter.empty? ? nil : ['sites.name LIKE ?', "%#{filter.query}%"]
    where(conditions)
  end
  
  def set_deployment_token
    self.deployment_token = Authlogic::Random.hex_token.first(32) if self.deployment_token.blank?
  end
end
