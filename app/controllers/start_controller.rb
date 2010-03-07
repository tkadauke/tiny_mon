class StartController < ApplicationController
  def index
    @check_runs = CheckRun.recent
    render :partial => '/start/activity' if request.xhr?
  end
end
