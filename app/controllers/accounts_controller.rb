class AccountsController < ApplicationController
  before_filter :login_required
  
  def index
    @accounts = current_user.accounts
  end
  
  def new
    @account = Account.new
  end
  
  def edit
    @account = Account.find(params[:id])
  end
  
  def create
    @account = Account.new(params[:account])
    if @account.save
      current_user.accounts << @account
      current_user.switch_to_account @account
      flash[:notice] = I18n.t('flash.notice.created_account', :account => @account.name)
      redirect_to root_path
    else
      render new_account_path
    end
  end
  
  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:notice] = I18n.t('flash.notice.updated_account', :account => @account.name)
      redirect_to account_path(@account)
    else
      render edit_account_path(@account)
    end
  end
  
  def switch
    @account = Account.find(params[:id])
    if current_user.can_switch_to_account?(@account)
      current_user.switch_to_account(@account)
      flash[:notice] = I18n.t('flash.notice.switched_account', :account => @account.name)
    else
      flash[:error] = I18n.t('flash.error.switch_account', :account => @account.name)
    end
    redirect_to root_path
  end
end
