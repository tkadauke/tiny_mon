require 'spec_helper'

describe HelpController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  describe "#create" do
    it_requires_login
    it_redirects_back

    it "stores setting" do
      call_action
      expect(user.soft_settings.get("help.show")).to eq('1')
    end
  end

  describe "#destroy" do
    it_redirects_back

    it "stores setting" do
      call_action
      expect(user.soft_settings.get("help.show")).to eq('0')
    end
  end
end
