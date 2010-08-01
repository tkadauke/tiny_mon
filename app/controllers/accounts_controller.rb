class AccountsController < ApplicationController
  before_filter :login_required
  before_filter :can_see_account_details!
  
  def index
    @accounts = current_user.accounts.ordered_by_name
  end
  
  def new
    @account = Account.new
  end
  
  def show
    @account = Account.find(params[:id])
    can_see_account!(@account)
  end
  
  def edit
    @account = Account.find(params[:id])
    can_edit_account!(@account)
  end
  
  def create
    @account = Account.new(params[:account])
    if @account.save
      current_user.accounts << @account
      current_user.set_role_for_account(@account, 'admin')
      current_user.switch_to_account @account
      flash[:notice] = I18n.t('flash.notice.created_account', :account => @account.name)
      redirect_to root_path
    else
      render :action => 'new'
    end
  end
  
  def update
    @account = Account.find(params[:id])
    can_edit_account!(@account) do
      if @account.update_attributes(params[:account])
        flash[:notice] = I18n.t('flash.notice.updated_account', :account => @account.name)
        redirect_to account_path(@account)
      else
        render :action => 'edit'
      end
    end
  end
  
  def switch
    @account = Account.find(params[:id])
    can_switch_to_account!(@account) do
      current_user.switch_to_account(@account)
      flash[:notice] = I18n.t('flash.notice.switched_account', :account => @account.name)
      redirect_to root_path
    end
  end
end
