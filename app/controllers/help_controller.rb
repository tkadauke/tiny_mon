class HelpController < ApplicationController
  def create
    current_user.soft_settings.set("help.show", '1')
    redirect_to :back
  end

  def destroy
    current_user.soft_settings.set("help.show", '0')
    redirect_to :back
  end
end
