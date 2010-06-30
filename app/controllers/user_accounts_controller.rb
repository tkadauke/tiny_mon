class UserAccountsController < ApplicationController
  before_filter :find_account
  
  def new
    can_add_user_to_account!(@account) do
      @user_account = @account.user_accounts.build
    end
  end
  
  def create
    can_add_user_to_account!(@account) do
      @user_account = @account.user_accounts.build(params[:user_account])
      if @user_account.save
        flash[:notice] = I18n.t('flash.notice.created_user_account')
        redirect_to new_account_user_account_path(@account)
      else
        render :action => 'new'
      end
    end
  end
  
  def destroy
    @user_account = @account.user_accounts.find(params[:id])
    can_remove_user_from_account!(@user_account.user, @account) do
      @user_account.destroy
      flash[:notice] = I18n.t('flash.notice.removed_user_account')
      redirect_to account_path(@account)
    end
  end
end
