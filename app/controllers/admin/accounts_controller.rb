class Admin::AccountsController < ApplicationController
  before_filter :login_required
  before_filter :can_see_all_accounts!
  
  def index
    @search_filter = SearchFilter.new(params[:search_filter])
    @accounts = Account.filter_for_list(@search_filter).paginate(:page => params[:page])
    render :update do |page|
      page.replace_html 'accounts', :partial => 'index'
    end if request.xhr?
  end
  
  def show
    @account = Account.find(params[:id])
  end
end
