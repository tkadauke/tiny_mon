require 'spec_helper'

describe DeploymentsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:site) { create(:site, :account => account) }
  let(:health_check) { create(:health_check, :site => site) }
  let(:deployment) { create(:deployment, :site => site) }

  let(:params) { { :locale => 'en', :account_id => account, :site_id => site.to_param } }

  before { login_with user }

  it_requires_login

  describe "#index" do
    before { @deployments = create_list(:deployment, 5, :site => site) }

    it_requires_params :account_id, :site_id
    it_returns_success
    it_paginates :deployments

    it "assigns deployments" do
      call_action
      expect(assigns(:deployments).to_a).to eq(@deployments)
    end
  end

  describe "#new" do
    it_requires_params :account_id, :site_id

    context "given user can create deployments" do
      it_returns_success
      it_assigns(:deployment) { be_new_record }
    end

    context "given user cannot create deployments" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#show" do
    before { params.merge!(:id => deployment) }
    before { @check_runs = create_list(:check_run, 5, :health_check => health_check, :deployment => deployment) }

    it_requires_params :account_id, :site_id, :id
    it_returns_success
    it_assigns(:deployment) { eq deployment }
    it_paginates :check_runs

    it "assigns check runs" do
      call_action
      expect(assigns(:check_runs).to_a).to eq(@check_runs)
    end
  end

  describe "#create" do
    context "given user can create deployments" do
      it_redirects
      it_shows_flash

      context "without deployment parameter" do
        it_changes("deployment count") { Deployment.count }
        it_does_not_change("check schedule") { health_check.reload.next_check_at }
      end

      context "with deployment parameter" do
        before { params.merge!(:deployment => { :revision => '0123456789', :schedule_checks_in => 30 }) }

        it_changes("deployment count") { Deployment.count }
        it_changes("check schedules") { health_check.reload.next_check_at }

        it_ignores_attributes :site_id => 0, :on => :deployment, :record => "Deployment.last"
        it_permits_attributes :revision => '97654321', :on => :deployment, :record => "Deployment.last"
      end

      context "with ID parameter" do
        it_requires_params :account_id, :site_id
        it_changes("deployment count") { Deployment.count }
      end

      context "with deployment token parameter" do
        let(:params) { { :locale => 'en', :token => site.deployment_token } }

        it_requires_params :token
        it_changes("deployment count") { Deployment.count }
      end
    end

    context "given user cannot create deployment" do
      before { demote(user, account) }

      it_shows_error
    end
  end
end
