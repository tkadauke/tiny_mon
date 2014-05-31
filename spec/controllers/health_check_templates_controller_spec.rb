require 'spec_helper'

describe HealthCheckTemplatesController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:health_check_template) { create(:health_check_template, :user => user, :account => account) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  it_requires_login

  describe "permissions" do
    context "given user cannot create health check templates" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#index" do
    before { @health_check_templates = create_list(:health_check_template, 5, :user => user, :account => account) }

    it_returns_success
    it_assigns(:health_check_templates) { eq @health_check_templates }
  end

  describe "#new" do
    it_returns_success
    it_assigns(:health_check_template) { be_new_record }
  end

  describe "#edit" do
    before { params.merge!(:id => health_check_template) }

    it_requires_params :id

    context "given user can edit template" do
      it_returns_success
      it_assigns(:health_check_template) { eq health_check_template }
    end

    context "given user cannot edit template" do
      before { user.user_account_for(account).destroy }

      it_shows_error
    end
  end

  describe "#create" do
    before do
      params.merge!(
        :health_check_template => {
          :name => 'Test template', :name_template => 'Testtest', :interval => 60,
          :variables_attributes => { "0" => { :name => "domain", :display_name => "Domain", :type => "string" } },
          :steps_attributes => { "0" => { :step_type => "visit", :step_data => { :url => "http://{{domain}}" } } }
        }
      )
    end

    context "given valid parameters" do
      it_changes("template count") { HealthCheckTemplate.count }
      it_changes("variable count") { HealthCheckTemplateVariable.count }
      it_changes("step count") { HealthCheckTemplateStep.count }
      it_redirects
      it_shows_flash

      it "assigns attributes to steps" do
        call_action
        expect(HealthCheckTemplateStep.last.step_data.data).to eq("url" => "http://{{domain}}")
      end

      it "sets user in template" do
        call_action
        expect(HealthCheckTemplate.last.user).to eq(user)
      end

      it "sets account in template" do
        call_action
        expect(HealthCheckTemplate.last.account).to eq(account)
      end
    end

    context "given invalid parameters" do
      before { params[:health_check_template].merge!(:interval => nil) }

      it_does_not_change("template count") { HealthCheckTemplate.count }
      it_returns_success
      it_renders :new
    end

    it_ignores_attributes :account_id => 0, :user_id => 0, :on => :health_check_template, :record => "HealthCheckTemplate.last"
    it_permits_attributes :name => "test", :name_template => "test2", :interval => 10, :on => :health_check_template, :record => "HealthCheckTemplate.last"
  end

  describe "#update" do
    before do
      params.merge!(
        :id => health_check_template,
        :health_check_template => {
          :name => 'Test template', :name_template => 'Test',
          :variables_attributes => { "0" => { :id => health_check_template.variables.first.id, :_destroy => true } },
          :steps_attributes => { "0" => { :id => health_check_template.steps.first.id, :step_type => "foo", :step_data => { :url => "http://{{address}}" } } }
        }
      )
    end

    it_requires_params :id

    context "given valid parameters" do
      context "given user can edit template" do
        it_redirects
        it_changes("template") { health_check_template.reload.name_template }
        it_changes("nested model count") { HealthCheckTemplateVariable.count }
        it_changes("nested model attributes") { health_check_template.steps.first.reload.step_data_hash['url'] }
      end

      context "given user cannot edit template" do
        before { user.user_account_for(account).destroy }

        it_shows_error
      end
    end

    context "given invalid parameters" do
      before { params.merge!(:id => health_check_template, :health_check_template => { :interval => nil }) }

      it_returns_success
      it_renders :edit
      it_assigns(:health_check_template) { eq health_check_template }
    end

    it_ignores_attributes :account_id => 0, :user_id => 0, :on => :health_check_template
    it_permits_attributes :name => "test", :name_template => "test2", :interval => 10, :on => :health_check_template
  end

  describe "#destroy" do
    before { params.merge!(:id => health_check_template) }

    it_requires_params :id

    context "given user can delete template" do
      it_changes("template count") { HealthCheckTemplate.count }
      it_redirects
      it_shows_flash
    end

    context "given user cannot delete template" do
      before { user.user_account_for(account).destroy }

      it_shows_error
    end
  end
end
