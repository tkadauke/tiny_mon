class StartController < ApplicationController
  before_filter :login_required
  
  def index
    @account = current_user.current_account
    
    if @account
      # disable account_id check because it's to slow
      # :conditions => ["sites.account_id = ?", @account.id]
      @check_runs = CheckRun.recent.all(:include => { :health_check => { :site => :account } })
      render :partial => '/check_runs/activity' if request.xhr?
    end
  end
end
