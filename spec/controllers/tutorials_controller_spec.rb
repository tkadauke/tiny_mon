require 'spec_helper'

describe TutorialsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  describe "#create" do
    before { params.merge!(:id => 'test_tutorial') }

    it_requires_login

    it "stores setting" do
      call_action
      expect(user.soft_settings.get("tutorials.current")).to eq('test_tutorial')
    end

    it_redirects_back
  end

  describe "#destroy" do
    it "deletes setting" do
      call_action
      expect(user.soft_settings.get("tutorials.current")).to be_nil
    end

    it_redirects_back
  end
end
