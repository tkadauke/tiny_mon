require 'spec_helper'

describe StartController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  it_requires_login

  describe "#index" do
    let(:site) { create(:site, :account => account) }
    let(:health_check) { create(:health_check, :site => site) }
    before { @check_runs = create_list(:check_run, 5, :health_check => health_check) }

    context "called normally" do
      it_returns_success
      it_assigns(:check_runs) { have(@check_runs.size).items }
      it_assigns(:upcoming_health_checks) { have(1).items }
    end

    context "called as XHR" do
      it_returns_success
      it_assigns(:check_runs) { have(@check_runs.size).items }
      it_renders "start/_dashboard"
    end
  end
end
