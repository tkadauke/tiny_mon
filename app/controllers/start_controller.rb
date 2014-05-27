class StartController < ApplicationController
  before_filter :login_required
  active_tab :start
  
  def index
    @account = current_user.current_account
    @page_title = t('.title')
    if @account
      # disable account_id check because it's to slow
      # :conditions => ["sites.account_id = ?", @account.id]
      @check_runs = @account.check_runs.where(:account_id => @account.id).order('started_at DESC').includes(:health_check )
      @upcoming_health_checks = @account.health_checks.upcoming.limit(10)
      render :partial => 'dashboard' if request.xhr?
    end
  end
end
