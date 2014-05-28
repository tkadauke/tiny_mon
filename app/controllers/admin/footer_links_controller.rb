class Admin::FooterLinksController < ApplicationController
  before_filter :login_required
  before_filter :can_edit_footer_links!
  
  def index
    @footer_links = FooterLink.ordered
  end
  
  def new
    @footer_link = FooterLink.new
  end
  
  def edit
    @footer_link = FooterLink.find(params[:id])
  end
  
  def create
    @footer_link = FooterLink.new(footer_link_params)
    if @footer_link.save
      flash[:notice] = I18n.t("flash.notice.created_footer_link")
      redirect_to admin_footer_links_path
    else
      render :action => 'new'
    end
  end
  
  def update
    @footer_link = FooterLink.find(params[:id])
    if @footer_link.update_attributes(footer_link_params)
      flash[:notice] = I18n.t("flash.notice.updated_footer_link")
      redirect_to admin_footer_links_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @footer_link = FooterLink.find(params[:id])
    @footer_link.destroy
    flash[:notice] = I18n.t("flash.notice.removed_footer_link")
    redirect_to admin_footer_links_path
  end
  
  def sort
    params[:link].each_with_index do |id, i|
      FooterLink.find(id).update_attribute(:position, i)
    end
    render :nothing => true
  end

  private
  def footer_link_params
    params.require(:footer_link).permit :text, :url
  end
end
