class Admin::UsersController < ApplicationController
  before_filter :login_required
  before_filter :can_see_all_users!

  def index
    @search_filter = SearchFilter.new(params[:search_filter])
    @users = User.filter_for_list(@search_filter).paginate(:page => params[:page])
  end
end
