class UserAccountsController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  
  respond_to :html, :xml, :json
  
  def index
    respond_with(@account.user_accounts_with_users, :include => :user) do |format|
      format.html do
        redirect_to account_path(@account)
      end
    end
  end
  
  def new
    can_add_user_to_account!(@account) do
      @user_account = @account.user_accounts.new
    end
  end
  
  def create
    can_add_user_to_account!(@account) do
      @user_account = @account.user_accounts.build(create_user_account_params)
      if @user_account.save
        @user_account.user.switch_to_account(@account) if @user_account.user.current_account.blank?
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
      if @user_account.update_attributes(update_user_account_params)
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

private
  def create_user_account_params
    params.require(:user_account).permit(:email)
  end

  def update_user_account_params
    params.require(:user_account).permit(:role)
  end
end
