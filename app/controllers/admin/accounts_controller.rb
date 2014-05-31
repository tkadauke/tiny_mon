class Admin::AccountsController < ApplicationController
  before_filter :login_required
  before_filter :can_see_all_accounts!
  before_filter :can_edit_all_accounts!, :only => [ :edit, :update ]
  
  def index
    @search_filter = SearchFilter.new(params[:search_filter])
    @accounts = Account.filter_for_list(@search_filter).paginate(:page => params[:page])
  end
  
  def show
    @account = Account.find(params[:id])
  end
  
  def edit
    @account = Account.find(params[:id])
  end
  
  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(account_params)
      flash[:notice] = I18n.t("flash.notice.updated_account", :account => @account.name)
      redirect_to admin_accounts_path
    else
      render :action => 'edit'
    end
  end

private
  def account_params
    params.require(:account).permit(:name, :maximum_check_runs_per_day)
  end
end
