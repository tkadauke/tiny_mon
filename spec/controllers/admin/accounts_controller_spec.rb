require 'spec_helper'

describe Admin::AccountsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :admin, :current_account => account) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  it_requires_login
  it_requires_admin

  describe "#index" do
    before { @accounts = create_list(:account, 5) }

    it_returns_success
    it_assigns(:search_filter) { be_a SearchFilter }
    it_assigns(:accounts) { include @accounts.first }
    it_paginates(:accounts)

    context "given a search filter" do
      before { params.merge!(:search_filter => { :query => 'foobar' }) }
      before { @other_account = create(:account, :name => 'foobar') }

      it_assigns(:accounts) { include @other_account }
    end
  end

  describe "#show" do
    before { params.merge!(:id => account) }

    it_requires_params :id
    it_returns_success
    it_assigns(:account) { eq account }
  end

  describe "#edit" do
    before { params.merge!(:id => account) }

    it_requires_params :id
    it_returns_success
    it_assigns(:account) { eq account }
  end

  describe "#update" do
    before { params.merge!(:id => account, :account => { :maximum_check_runs_per_day => 1000 }) }

    it_requires_params :id

    context "given valid parameters" do
      it_changes("account") { account.reload.maximum_check_runs_per_day }
      it_redirects
    end

    context "given invalid parameters" do
      before { params[:account].merge!(:name => nil) }

      it_does_not_change("account") { account.reload.name }
      it_returns_success
      it_renders :edit
    end

    it_ignores_attributes :check_runs_per_day => 5, :on => :account
    it_permits_attributes :name => 'foobar', :maximum_check_runs_per_day => 10000, :on => :account
  end
end
