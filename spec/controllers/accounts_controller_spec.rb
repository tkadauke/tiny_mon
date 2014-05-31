require 'spec_helper'

describe AccountsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }

  let(:params) { { :locale => 'en' } }
  let(:json) { JSON.parse(response.body) }

  before { login_with user }

  it_requires_login

  context "#index" do
    it_assigns(:accounts) { eq([account]) }
    it_returns_success

    context "with JSON format" do
      before { params.merge!(:format => 'json') }

      it "returns accounts" do
        call_action
        expect(json).to have(1).items
      end
    end
  end

  context "#new" do
    it_assigns(:account) { be_new_record }
    it_returns_success
  end

  context "#show" do
    before { params.merge!(:id => account) }

    it_requires_params :id

    context "given user can see the account" do
      it_assigns(:account) { eq(account) }
      it_returns_success

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it "returns account" do
          call_action
          expect(json['id']).to eq(account.id)
        end
      end
    end

    context "given user cannot see the account" do
      before { user.user_account_for(account).destroy }

      it_shows_error
    end
  end

  context "#edit" do
    before { params.merge!(:id => account) }

    it_requires_params :id

    context "given user can edit the account" do
      it_assigns(:account) { eq(account) }
      it_returns_success
    end

    context "given user cannot edit the account" do
      before { user.set_role_for_account(account, 'user') }

      it_shows_error
    end
  end

  context "#create" do
    before { params.merge!(:account => { :name => 'other account' }) }

    context "given valid parameters" do
      it "sets user's role to admin" do
        call_action
        expect(user.user_account_for(Account.last).role).to eq('admin')
      end

      it_changes("account count") { Account.count }
      it_changes("user account count") { UserAccount.count }
      it_changes("user's current account") { user.reload.current_account }
      it_shows_flash
      it_redirects
    end

    context "given invalid parameters" do
      before { params[:account].merge!(:name => nil) }

      it_does_not_change("account count") { Account.count }
      it_returns_success
      it_assigns(:account) { be_new_record }
      it_renders :new
      it_shows_no_flash
    end

    it_ignores_attributes :maximum_check_runs_per_day => 1000, :on => :account, :record => 'Account.last'
    it_permits_attributes :name => 'some account', :on => :account, :record => 'Account.last'
  end

  context "#update" do
    before { params.merge!(:id => account, :account => { :name => 'changed name' }) }

    it_requires_params :id

    context "given valid parameters" do
      it_changes("account name") { account.reload.name }
      it_redirects
      it_shows_flash
    end

    context "given invalid parameters" do
      before { params[:account].merge!(:name => nil) }

      it_does_not_change("account") { account.reload }
      it_returns_success
      it_shows_no_flash
    end

    it_ignores_attributes :maximum_check_runs_per_day => 1000, :on => :account
    it_permits_attributes :name => 'some account', :on => :account
  end

  context "#switch" do
    before { params.merge!(:id => second_account) }

    context "given user belongs to account" do
      let(:second_account) { user.accounts.create(:name => 'second account') }

      it_requires_params :id
      it_changes("current account") { user.reload.current_account }
      it_shows_flash

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it_changes("current account") { user.reload.current_account }
      end
    end

    context "given user does not belong to account" do
      let(:second_account) { Account.create(:name => 'second account') }

      it_does_not_change("current account") { user.reload.current_account }
      it_shows_error
    end
  end
end
