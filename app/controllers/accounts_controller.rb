class AccountsController < ApplicationController
  before_filter :login_required
  before_filter :can_see_account_details!
  
  respond_to :html, :xml, :json
  
  def index
    @accounts = current_user.accounts.ordered_by_name
    respond_with @accounts, :for => current_user
  end
  
  def new
    @account = Account.new
  end
  
  def show
    @account = Account.find(params[:id])
    can_see_account!(@account)
    respond_with @account, :for => current_user
  end
  
  def edit
    @account = Account.find(params[:id])
    can_edit_account!(@account)
  end
  
  def create
    @account = Account.new(account_params)
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
      if @account.update_attributes(account_params)
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
      respond_with @account, :for => current_user, :location => root_path
    end
  end


  private
  def account_params
    params.require(:account).permit :name, :id
  end
end
