require 'spec_helper'

describe ScreenshotsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:site) { create(:site, :account => account) }
  let(:health_check) { create(:health_check, :site => site) }
  let(:check_run) { create(:check_run, :health_check => health_check) }
  let(:screenshot) { create(:screenshot, :check_run => check_run) }

  let(:params) { { :locale => 'en', :account_id => account, :site_id => site.to_param, :health_check_id => health_check.to_param, :check_run_id => check_run.id } }

  before { login_with user }

  it_requires_login

  describe "#index" do
    before { @screenshots = create_list(:screenshot, 5, :check_run => check_run) }

    it_requires_params :account_id, :site_id, :health_check_id
    it_returns_success
    it_paginates :screenshots

    it "assigns screenshots" do
      call_action
      expect(assigns(:screenshots).to_a).to eq(@screenshots)
    end
  end

  describe "#show" do
    before { params.merge!(:id => screenshot) }

    it_requires_params :account_id, :site_id, :health_check_id, :check_run_id, :id

    it_returns_success
    it_assigns(:screenshot) { eq screenshot }
  end
end
