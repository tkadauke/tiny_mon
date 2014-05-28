class TutorialsController < ApplicationController

  def create
    current_user.soft_settings.set("tutorials.current", params[:id])
    redirect_to :back
  end
  
  def destroy
    current_user.soft_settings.unset("tutorials.current")
    redirect_to :back
  end
end
