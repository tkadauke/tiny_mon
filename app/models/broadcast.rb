class Broadcast < ActiveRecord::Base
  validates_presence_of :title, :text
  
  scope :ordered, order('broadcasts.sent_at DESC')
  
  def name
    title
  end
  
  def self.from_param!(param)
    find(param)
  end
  
  def deliver
    User.all.each do |user|
      begin
        I18n.with_locale user.config.language do
          BroadcastMailer.broadcast(self, user).deliver
        end if user.config.broadcasts_enabled
      rescue
        # ignore delivery errors
      end
    end
    update_attribute(:sent_at, Time.now)
  end
  background_method :deliver
end
