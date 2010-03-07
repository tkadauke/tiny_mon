class StartController < ApplicationController
  def index
    @check_runs = CheckRun.recent
    render :partial => '/check_runs/activity' if request.xhr?
  end
end
