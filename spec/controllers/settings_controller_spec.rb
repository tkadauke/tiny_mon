require 'spec_helper'

describe SettingsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  describe "#show" do
    it_requires_login
    it_returns_success
    it_assigns(:configuration) { be_a User::Configuration }
  end

  describe "#create" do
    before { params.merge!(:configuration => { :prowl_enabled => '1' }) }

    it "updates configuration" do
      call_action
      expect(user.reload.config.prowl_enabled).to be_true
    end

    it_shows_flash
    it_redirects
  end
end
