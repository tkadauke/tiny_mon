class UserAccountsController < ApplicationController
  before_filter :find_account
  
  def new
    @user_account = @account.user_accounts.build
  end
  
  def create
    @user_account = @account.user_accounts.build(params[:user_account])
    if @user_account.save
      flash[:notice] = I18n.t('flash.notice.created_user_account')
      redirect_to new_account_user_account_path(@account)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @user_account = @account.user_accounts.find(params[:id])
    @user_account.destroy
    redirect_to account_path(@account)
  end
end
