require 'spec_helper'

describe CommentsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:site) { create(:site, :account => account) }
  let(:health_check) { create(:health_check, :site => site) }
  let(:check_run) { create(:check_run, :health_check => health_check) }

  let(:params) { { :locale => 'en', :account_id => account, :site_id => site.to_param, :health_check_id => health_check.to_param } }

  before { login_with user }

  it_requires_login

  describe "#index" do
    before { @comments = create_list(:comment, 5, :check_run => check_run, :user => user) }

    it_requires_params :account_id, :site_id, :health_check_id

    context "for check run" do
      before { params.merge!(:check_run_id => check_run.id) }

      it_requires_params :check_run_id
      it_returns_success
      it_assigns(:comment) { be_new_record }

      it "assigns comments from check run" do
        call_action
        expect(assigns(:comments).to_a).to eq(@comments)
      end
    end

    context "for health check" do
      let(:other_check_run) { create(:check_run, :health_check => health_check) }
      before { @other_comments = create_list(:comment, 3, :check_run => other_check_run, :user => user) }

      it_returns_success

      it "assigns comments" do
        call_action
        expect(assigns(:comments).to_a).to eq(@comments + @other_comments)
      end
    end

    context "for user" do
      let(:params) { { :locale => 'en', :user_id => user.id } }
      let(:other_health_check) { create(:health_check, :site => site) }
      let(:other_check_run) { create(:check_run, :health_check => other_health_check) }
      before { @other_comments = create_list(:comment, 3, :check_run => other_check_run, :user => user) }

      it_requires_params :user_id
      it_returns_success

      it "assigns comments" do
        call_action
        expect(assigns(:comments).to_a).to eq(@comments + @other_comments)
      end
    end
  end

  describe "#new" do
    before { params.merge!(:check_run_id => check_run.id) }

    it_requires_params :account_id, :site_id, :health_check_id

    context "given user can create comments" do
      it_returns_success
      it_assigns(:comment) { be_new_record }
    end

    context "given user cannot create comments" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#create" do
    before { params.merge!(:check_run_id => check_run.id, :comment => { :text => 'foobar' }) }

    it_requires_params :account_id, :site_id, :health_check_id

    context "given user can create comments" do
      context "given valid parameters" do
        it "sets user in comment" do
          call_action
          expect(Comment.last.user).to eq(user)
        end

        it_changes("comment count") { Comment.count }
        it_shows_flash
        it_redirects
      end

      context "given invalid parameters" do
        before { params.merge!(:comment => { :text => nil }) }

        it_does_not_change("comment count") { Comment.count }
        it_returns_success
        it_renders :new
      end

      it_ignores_attributes :check_run_id => 0, :account_id => 0, :user_id => 0, :on => :comment, :record => "Comment.last"
      it_permits_attributes :title => 'hello', :text => 'world', :on => :comment, :record => "Comment.last"
    end

    context "given user cannot create comments" do
      before { demote(user, account) }

      it_shows_error
    end
  end
end
