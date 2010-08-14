class UserAccountsController < ApplicationController
  before_filter :find_account
  
  def index
    redirect_to account_path(@account)
  end
  
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
  
  def update
    @user_account = UserAccount.find(params[:id])
    can_assign_role_for_user_and_account!(@user_account.user, @account) do
      if @user_account.update_attributes(params[:user_account])
        flash[:notice] = I18n.t('flash.notice.assign_roles')
      else
        flash[:error] = I18n.t('flash.error.assign_roles')
      end
      redirect_to account_path(@account)
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
