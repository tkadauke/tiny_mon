class AdminController < ApplicationController
  before_filter :login_required
  before_filter :can_enter_admin_area!
  
  def index
  end
end
