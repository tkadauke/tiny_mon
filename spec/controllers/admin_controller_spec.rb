require 'spec_helper'

describe AdminController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :admin, :current_account_id => account.id) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  it_requires_login
  it_requires_admin

  context "given user is admin" do
    it_returns_success
  end
end
