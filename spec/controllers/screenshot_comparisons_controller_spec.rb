require 'spec_helper'

describe ScreenshotComparisonsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:site) { create(:site, :account => account) }
  let(:health_check) { create(:health_check, :site => site) }
  let(:check_run) { create(:check_run, :health_check => health_check) }

  let(:params) { { :locale => 'en', :account_id => account, :site_id => site.to_param, :health_check_id => health_check.to_param, :check_run_id => check_run.id } }

  before { login_with user }

  it_requires_login

  describe "#index" do
    it_requires_params :account_id, :site_id, :health_check_id, :check_run_id
    it_redirects
  end

  describe "#show" do
    let(:screenshot1) { create(:screenshot, :check_run => check_run) }
    let(:screenshot2) { create(:screenshot, :check_run => check_run) }
    let(:screenshot_comparison) { create(:screenshot_comparison, :check_run => check_run, :first_screenshot => screenshot1, :second_screenshot => screenshot2) }
    before { params.merge!(:id => screenshot_comparison.id) }

    it_requires_params :account_id, :site_id, :health_check_id, :check_run_id, :id

    it_returns_success
    it_assigns(:screenshot_comparison) { eq screenshot_comparison }
  end
end
