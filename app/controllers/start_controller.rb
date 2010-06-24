class StartController < ApplicationController
  before_filter :login_required
  
  def index
    @account = current_user.current_account
    
    if @account
      @check_runs = CheckRun.recent.all(:include => { :health_check => :site }, :conditions => ["sites.account_id = ?", @account.id])
      render :partial => '/check_runs/activity' if request.xhr?
    end
  end
end
