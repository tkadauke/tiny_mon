class Admin::UsersController < ApplicationController
  before_filter :login_required
  before_filter :can_see_all_users!

  def index
    @search_filter = SearchFilter.new(params[:search_filter])
    @users = User.paginate_for_list(@search_filter, :page => params[:page])
    render :update do |page|
      page.replace_html 'users', :partial => 'index'
    end if request.xhr?
  end
end
