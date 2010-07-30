class Admin::AccountsController < ApplicationController
  before_filter :login_required
  before_filter :can_edit_footer_links!
  
  def index
    @search_filter = SearchFilter.new(params[:search_filter])
    @accounts = Account.paginate_for_list(@search_filter, :page => params[:page])
    render :update do |page|
      page.replace_html 'accounts', :partial => 'index'
    end if request.xhr?
  end
  
  def show
    @account = Account.find(params[:id])
  end
end
