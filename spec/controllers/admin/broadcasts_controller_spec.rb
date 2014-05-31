require 'spec_helper'

describe Admin::BroadcastsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :admin, :current_account => account) }
  let(:broadcast) { create(:broadcast) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  it_requires_login
  it_requires_admin

  describe "#index" do
    before { @broadcasts = create_list(:broadcast, 5) }

    it_returns_success
    it_assigns(:broadcasts) { eq @broadcasts }
  end

  describe "#new" do
    it_returns_success
    it_assigns(:broadcast) { be_new_record }
  end

  describe "#show" do
    before { params.merge!(:id => broadcast) }

    it_requires_params :id
    it_returns_success
    it_assigns(:broadcast) { eq broadcast }
  end

  describe "#edit" do
    before { params.merge!(:id => broadcast) }

    it_requires_params :id
    it_returns_success
    it_assigns(:broadcast) { eq broadcast }
  end

  context "#create" do
    before { params.merge!(:broadcast => { :title => 'whats up', :text => 'nothing to say' }) }

    context "given valid parameters" do
      it_changes("broadcast count") { Broadcast.count }
      it_shows_flash
      it_redirects
    end

    context "given invalid parameters" do
      before { params[:broadcast].merge!(:title => nil) }

      it_does_not_change("broadcast count") { Broadcast.count }
      it_returns_success
      it_assigns(:broadcast) { be_new_record }
      it_renders :new
      it_shows_no_flash
    end

    it_ignores_attributes :sent_at => Time.now, :on => :broadcast, :record => "Broadcast.last"
    it_permits_attributes :title => 'hello', :text => 'world', :on => :broadcast, :record => "Broadcast.last"
  end

  describe "#update" do
    before { params.merge!(:id => broadcast, :broadcast => { :title => 'good bye', :text => 'everyone' }) }

    it_requires_params :id

    context "given valid parameters" do
      it_changes("broadcast") { broadcast.reload.title }
      it_redirects
    end

    context "given invalid parameters" do
      before { params[:broadcast].merge!(:title => nil) }

      it_does_not_change("broadcast") { broadcast.reload.title }
      it_returns_success
      it_renders :edit
    end

    it_ignores_attributes :sent_at => Time.now, :on => :broadcast
    it_permits_attributes :title => 'hello', :text => 'world', :on => :broadcast
  end

  describe "#destroy" do
    before { params.merge!(:id => broadcast) }

    it_requires_params :id
    it_changes("broadcast count") { Broadcast.count }
    it_redirects
    it_shows_flash
  end

  describe "#deliver" do
    let(:verb) { :post }
    before { params.merge!(:id => broadcast) }

    it_requires_params :id
    it_changes("sent timestamp") { broadcast.reload.sent_at }
    it_shows_flash
    it_redirects
  end
end
