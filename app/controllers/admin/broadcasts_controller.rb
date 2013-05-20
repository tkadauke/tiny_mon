class Admin::BroadcastsController < ApplicationController
  before_filter :login_required
  before_filter :can_edit_broadcasts!
  
  def index
    @broadcasts = Broadcast.ordered
  end
  
  def new
    @broadcast = Broadcast.new
  end
  
  def show
    @broadcast = Broadcast.find(params[:id])
  end
  
  def edit
    @broadcast = Broadcast.find(params[:id])
  end
  
  def create
    @broadcast = Broadcast.new(params[:broadcast])
    if @broadcast.save
      flash[:notice] = I18n.t("flash.notice.created_broadcast")
      redirect_to admin_broadcasts_path
    else
      render :action => 'new'
    end
  end
  
  def update
    @broadcast = Broadcast.find(params[:id])
    if @broadcast.update_attributes(params[:broadcast])
      flash[:notice] = I18n.t("flash.notice.updated_broadcast")
      redirect_to admin_broadcasts_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @broadcast = Broadcast.find(params[:id])
    @broadcast.destroy
    flash[:notice] = I18n.t("flash.notice.removed_broadcast")
    redirect_to admin_broadcasts_path
  end
  
  def deliver
    @broadcast = Broadcast.find(params[:id])
    @broadcast.deliver
    flash[:notice] = I18n.t("flash.notice.sent_broadcast")
    redirect_to admin_broadcasts_path
  end
end
