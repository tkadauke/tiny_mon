require 'spec_helper'

describe UserAccountsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }

  let(:params) { { :locale => 'en', :account_id => account } }
  let(:json) { JSON.parse(response.body) }

  before { login_with user }

  it_requires_login

  describe "#index" do
    it_redirects
    it_requires_params :account_id

    context "with JSON format" do
      before { params.merge!(:format => 'json') }

      it "returns accounts" do
        call_action
        expect(json).to have(1).items
      end

      it "includes users" do
        call_action
        expect(json.first).to have_key('user')
      end
    end
  end

  describe "#new" do
    it_requires_params :account_id

    context "given user can add others to account" do
      it_returns_success
      it_assigns(:user_account) { be_new_record }
    end

    context "given user cannot add others to account" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#create" do
    it_requires_params :account_id

    context "with existing user" do
      let(:second_user) { create(:user, :email => 'jane.doe@example.com') }
      before { second_user }
      before { params.merge!(:user_account => { :email => 'jane.doe@example.com' }) }

      context "given user can add others to account" do
        it_changes("user account count") { UserAccount.count }
        it_redirects
        it_shows_flash
        it_changes("switch permission for second user") { second_user.reload.can_switch_to_account?(account) }

        context "given user has no account" do
          it_changes("current account") { second_user.reload.current_account }
        end

        context "given user has an account" do
          let(:new_account) { create(:account) }
          let(:second_user) { create(:user, :current_account => new_account, :email => 'jane.doe@example.com') }

          it_does_not_change("current account") { second_user.reload.current_account }
        end

        it_ignores_attributes :role => 'admin', :on => :user_account, :record => "UserAccount.last"
      end

      context "given user cannot add others to account" do
        before { demote(user, account) }

        it_shows_error
      end
    end

    context "without existing user" do
      before { params.merge!(:user_account => { :email => 'foobar.com' }) }

      it_requires_params :account_id
      it_does_not_change("user account count") { UserAccount.count }
      it_returns_success
      it_renders :new
      it_assigns(:user_account) { be_new_record }
      it_shows_no_flash

      it "is invalid" do
        call_action
        expect(assigns(:user_account).errors[:email]).not_to be_blank
      end
    end
  end

  describe "#update" do
    let(:second_user) { create(:user, :current_account => account, :email => 'jane.doe@example.com') }
    before { second_user }
    before { params.merge!(:id => UserAccount.last, :user_account => { :role => 'admin' }) }

    it_requires_params :account_id, :id

    context "given user can assign role to others in account" do
      it_changes("user account role") { UserAccount.last.role }
      it_redirects
      it_shows_flash
    end

    context "given user cannot assign role to others in account" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#destroy" do
    let(:second_user) { create(:user, :current_account => account, :email => 'jane.doe@example.com') }
    before { second_user }
    before { params.merge!(:id => UserAccount.last) }

    it_requires_params :account_id, :id

    context "given user can remove others from account" do
      it_changes("user account count") { UserAccount.count }
      it_redirects
      it_shows_flash
    end

    context "given user cannot remove others from account" do
      before { demote(user, account) }

      it_shows_error
    end
  end
end
