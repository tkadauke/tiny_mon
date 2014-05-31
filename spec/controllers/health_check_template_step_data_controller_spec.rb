require 'spec_helper'

describe HealthCheckTemplateStepDataController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }

  let(:params) { { :locale => 'en', :step_type => 'visit' } }

  before { login_with user }

  describe "#new" do
    context "called as XHR" do
      it_requires_login
      it_requires_params :account_id
      it_returns_success
      it_renders "health_check_template_step_data/_step_data_form"

      context "given user cannot create health check templates" do
        before { demote(user, account) }

        it_shows_error
      end
    end
  end
end
