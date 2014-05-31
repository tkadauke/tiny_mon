require 'spec_helper'

describe UsersController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }

  let(:params) { { :locale => 'en' } }
  let(:json) { JSON.parse(response.body) }

  before { login_with user }

  it_requires_login

  describe "#index" do
    it "redirects to accounts path" do
      call_action
      expect(response).to redirect_to(account_path(account))
    end
  end

  describe "#new" do
    it_assigns(:user) { be_new_record }

    context "logged in" do
      it_returns_success
    end

    context "logged out" do
      before { logout }

      it_returns_success
    end
  end

  describe "#create" do
    before { params.merge!(:user => { :full_name => "John Doe", :password => "12345", :password_confirmation => "12345", :email => "john@doe.com" }) }

    context "logged out" do
      before { logout }

      describe "given valid parameters" do
        it_changes("user count") { User.count }
        it_shows_flash
        it_redirects
      end

      describe "given invalid parameters" do
        before { params[:user].merge!(:full_name => nil) }

        it_does_not_change("user count") { User.count }
        it_returns_success
        it_renders :new
      end

      it_ignores_attributes :crypted_password => "foo", :password_salt => "foo", :persistence_token => "foo",
                            :single_access_token => "foo", :perishable_token => "foo", :login_count => 100,
                            :failed_login_count => 100, :current_login_ip => "8.8.8.8", :last_login_ip => "8.8.8.8",
                            :current_account_id => 0, :role => "admin",
                            :on => :user, :record => "User.last"
      it_permits_attributes :full_name => "Jane Doe", :email => "jane@doe.com",
                            :on => :user, :record => "User.last"
    end

    describe "logged in" do
      before { params.merge!(:user => { :full_name => "Jane Doe", :password => "12345", :password_confirmation => "12345", :email => "jane@doe.com" }) }

      it_changes("user account count") { UserAccount.count }
      it_changes("user count") { User.count }
      it_redirects
    end
  end

  describe "#show" do
    before { params.merge!(:id => user.id) }

    it_requires_params :id

    context "given user can see profile" do
      it_returns_success
      it_assigns(:user) { eq user }

      describe "comments" do
        let(:site) { create(:site, :account => account) }
        let(:health_check) { create(:health_check, :site => site) }
        let(:check_run) { create(:check_run, :health_check => health_check) }
        before { @comments = create_list(:comment, 5, :check_run => check_run, :user => user, :account => account) }

        it "assigns comments" do
          call_action
          expect(assigns(:comments).to_a.sort_by(&:id)).to eq(@comments.sort_by(&:id))
        end

        it_assigns(:comments_count) { eq @comments.size }
      end

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it "returns user" do
          call_action
          expect(json['id']).to eq(user.id)
        end

        it "includes accounts" do
          call_action
          expect(json).to have_key("accounts")
        end
      end
    end

    context "given user cannot see profile" do
      let(:another_user) { create(:user) }
      before { params.merge!(:id => another_user.id) }

      it_shows_error
    end
  end

  describe "#edit" do
    before { params.merge!(:id => user.id) }

    it_requires_params :id

    it_returns_success
    it_assigns(:user) { eq user }
  end

  describe "#update" do
    before { params.merge!(:id => user.id, :user => { :full_name => "Jane Doe" }) }

    it_requires_params :id

    context "given valid parameters" do
      it_changes("user") { user.reload.full_name }
      it_shows_flash
      it_redirects
    end

    context "given invalid parameters" do
      before { params[:user].merge!(:full_name => nil) }

      it_does_not_change("user") { user.reload.full_name }
      it_returns_success
      it_renders :edit
    end

    it_ignores_attributes :crypted_password => "foo", :password_salt => "foo", :persistence_token => "foo",
                          :single_access_token => "foo", :perishable_token => "foo", :login_count => 100,
                          :failed_login_count => 100, :current_login_ip => "8.8.8.8", :last_login_ip => "8.8.8.8",
                          :current_account_id => 0, :role => "admin",
                          :on => :user
    it_permits_attributes :full_name => "Jane Doe", :email => "jane@doe.com",
                          :on => :user
  end
end
