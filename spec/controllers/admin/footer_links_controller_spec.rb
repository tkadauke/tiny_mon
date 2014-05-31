require 'spec_helper'

describe Admin::FooterLinksController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :admin, :current_account => account) }
  let(:footer_link) { create(:footer_link) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  it_requires_login
  it_requires_admin
  
  describe "#index" do
    before { @footer_links = create_list(:footer_link, 5) }

    it_returns_success
    it_assigns(:footer_links) { eq @footer_links }
  end

  describe "#new" do
    it_returns_success
    it_assigns(:footer_link) { be_new_record }
  end

  describe "#edit" do
    before { params.merge!(:id => footer_link) }

    it_requires_params :id
    it_returns_success
    it_assigns(:footer_link) { eq footer_link }
  end

  context "#create" do
    before { params.merge!(:footer_link => { :text => 'google', :url => 'http://www.google.com' }) }

    context "given valid parameters" do
      it_changes("footer_link count") { FooterLink.count }
      it_shows_flash
      it_redirects
    end

    context "given invalid parameters" do
      before { params[:footer_link].merge!(:text => nil) }

      it_does_not_change("footer_link count") { FooterLink.count }
      it_returns_success
      it_assigns(:footer_link) { be_new_record }
      it_renders :new
      it_shows_no_flash
    end

    it_ignores_attributes :position => 17, :on => :footer_link, :record => "FooterLink.last"
    it_permits_attributes :text => 'yahoo', :url => 'http://www.yahoo.com', :on => :footer_link, :record => "FooterLink.last"
  end

  describe "#update" do
    before { params.merge!(:id => footer_link, :footer_link => { :text => 'google', :url => 'http://www.google.com' }) }

    it_requires_params :id

    context "given valid parameters" do
      it_changes("footer_link") { footer_link.reload.text }
      it_redirects
    end

    context "given invalid parameters" do
      before { params[:footer_link].merge!(:text => nil) }

      it_does_not_change("footer_link") { footer_link.reload.text }
      it_returns_success
      it_renders :edit
    end

    it_ignores_attributes :position => 17, :on => :footer_link
    it_permits_attributes :text => 'yahoo', :url => 'http://www.yahoo.com', :on => :footer_link
  end

  describe "#destroy" do
    before { params.merge!(:id => footer_link) }

    it_requires_params :id
    it_changes("footer link count") { FooterLink.count }
    it_redirects
    it_shows_flash
  end

  describe "#sort" do
    let(:another_link) { create(:footer_link) }
    before { params.merge!(:link => [another_link.id, footer_link.id]) }

    it "sorts steps" do
      call_action
      expect([footer_link.reload.position, another_link.reload.position]).to eq([1, 0])
    end

    it_returns_nothing
  end
end
