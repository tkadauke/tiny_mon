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
    health_checks.count(:conditions => { :status => 'failure', :enabled => true }) == 0
  end
  
  def self.from_param!(param)
    find_by_permalink!(param)
  end
  
  def self.find_for_list(filter)
    with_search_scope(filter) do
      find(:all, :include => :account, :order => 'sites.name ASC')
    end
  end

protected
  def self.with_search_scope(filter, &block)
    conditions = filter.empty? ? nil : ['sites.name LIKE ?', "%#{filter.query}%"]
    with_scope :find => { :conditions => conditions } do
      yield
    end
  end
  
  def set_deployment_token
    self.deployment_token = Authlogic::Random.hex_token.first(32) if self.deployment_token.blank?
  end
end
