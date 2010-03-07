class StartController < ApplicationController
  def index
    @check_runs = CheckRun.recent.all(:include => { :health_check => :site })
    render :partial => '/check_runs/activity' if request.xhr?
  end
end
