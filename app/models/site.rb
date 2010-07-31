class Site < ActiveRecord::Base
  belongs_to :account
  has_many :health_checks, :dependent => :destroy
  
  has_permalink :name
  
  validates_presence_of :name, :url
  
  def to_param
    permalink
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
end
