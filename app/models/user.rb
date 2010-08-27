class User < ActiveRecord::Base
  acts_as_user
  has_accounts
  
  has_many :soft_settings
  has_many :config_options
  has_many :comments
  has_many :latest_comments, :class_name => 'Comment', :order => 'created_at DESC'
  
  has_many :health_check_templates
  
  def config
    @config ||= User::Configuration.new(self)
  end
  
  def latest_comments_for_user(user, options = {})
    latest_comments.find(:all, options.merge(:conditions => ['account_id in (?)', user.accounts.map(&:id)]))
  end

  def comments_count_for_user(user)
    latest_comments.count(:conditions => ['account_id in (?)', user.accounts.map(&:id)])
  end
  
  def comments_for_user(user, options = {})
    comments.find(:all, options.merge(:conditions => ['account_id in (?)', user.accounts.map(&:id)]))
  end
  
  def available_health_check_templates(options = {})
    HealthCheckTemplate.paginate(options.update(:conditions => ['user_id = ? or account_id in (?) or public', self.id, accounts.map(&:id)], :order => 'name ASC'))
  end
end
