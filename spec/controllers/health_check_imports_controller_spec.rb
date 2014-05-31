require 'spec_helper'
require 'csv'

describe HealthCheckImportsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:site) { create(:site, :account => account) }
  let(:health_check_template) { create(:health_check_template, :user => user) }

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
    context "for site" do
      before { @imports = create_list(:site_health_check_import, 5, :user => user, :account => account, :site => site, :health_check_template => health_check_template) }
      before { params.merge!(:account_id => account.id, :site_id => site.permalink) }

      it_requires_params :account_id, :site_id
      it_returns_success

      it "assigns imports" do
        call_action
        expect(assigns(:health_check_imports).to_a).to eq(@imports)
      end
    end

    context "for account" do
      before { @imports = create_list(:account_health_check_import, 5, :user => user, :account => account, :health_check_template => health_check_template) }

      it_returns_success

      it "assigns imports" do
        call_action
        expect(assigns(:health_check_imports).to_a).to eq(@imports)
      end
    end
  end

  describe "#show" do
    let(:import) { create(:account_health_check_import, :user => user, :account => account, :health_check_template => health_check_template) }
    before { params.merge!(:id => import.id) }

    it_requires_params :id
    it_returns_success
    it_assigns(:health_check_import) { eq import }
    it_assigns(:health_checks) { eq import.health_checks }
    it_assigns(:search_filter) { be_a SearchFilter }
  end

  describe "#new" do
    before do
      @my_template = create(:health_check_template, :user => user)
      @other_users_private_template = create(:health_check_template, :user => create(:user), :public => false)
      @other_users_public_template = create(:health_check_template, :user => create(:user), :public => true)
      @private_account_template = create(:health_check_template, :account => account, :user => create(:user), :public => false)
    end

    context "without template parameter" do
      context "without filter" do
        it_returns_success
        it_assigns(:health_check_templates) { eq [@my_template, @other_users_public_template, @private_account_template] }
      end

      context "with 'mine' filter" do
        before { params.merge!(:filter => 'mine') }

        it_returns_success
        it_assigns(:health_check_templates) { eq [@my_template] }
      end

      context "with 'account' filter" do
        before { params.merge!(:filter => 'account') }

        it_returns_success
        it_assigns(:health_check_templates) { eq [@private_account_template] }
      end

      context "with 'public' filter" do
        before { params.merge!(:filter => 'public') }

        it_returns_success
        it_assigns(:health_check_templates) { eq [@other_users_public_template] }
      end

      context "for site" do
        before { params.merge!(:account_id => account.id, :site_id => site.permalink) }

        it_requires_params :account_id, :site_id
        it_returns_success
      end
    end

    context "with template parameter" do
      context "for site" do
        before { params.merge!(:account_id => account.id, :site_id => site.permalink, :template => health_check_template.id) }

        it_requires_params :account_id, :site_id
        it_returns_success
        it_assigns(:health_check_template) { eq health_check_template }
        it_assigns(:health_check_import) { be_new_record }
        it_does_not_assign(:health_check_templates)
      end

      context "for account" do
        before { params.merge!(:template => health_check_template.id) }

        it_returns_success
      end
    end
  end

  describe "#create" do
    context "given preview is selected" do
      before { params.merge!(:commit => 'Preview') }

      context "for site" do
        let(:csv) { [
          ['www.google.com'].to_csv,
          ['www.wikipedia.org'].to_csv
        ].join }

        before { params.merge!(:account_id => account.id, :site_id => site.permalink, :health_check_import => { :health_check_template_id => health_check_template.id, :csv_data => csv }) }

        it_requires_params :account_id, :site_id
        it_does_not_change("health check count") { HealthCheck.count }
        it_returns_success
        it_renders :new
        it_assigns(:preview) { be_true }
      end

      context "for account" do
        let(:csv) { [
          ['first_site', 'Google', 'http://www.google.com'].to_csv,
          ['second_site', 'Wikipedia', 'http://www.wikipedia.org'].to_csv
        ].join }

        before { params.merge!(:health_check_import => { :health_check_template_id => health_check_template.id, :csv_data => csv }) }

        it_does_not_change("health check count") { HealthCheck.count }
        it_returns_success
        it_renders :new
        it_assigns(:preview) { be_true }
      end
    end

    context "given import is selected" do
      before { params.merge!(:commit => 'Import') }

      context "either way" do
        let(:csv) { [
          ['www.google.com'].to_csv,
          ['www.wikipedia.org'].to_csv
        ].join }

        before { params.merge!(:account_id => account.id, :site_id => site.permalink, :health_check_import => { :health_check_template_id => health_check_template.id, :csv_data => csv }) }

        it_requires_params :account_id, :site_id
        it_assigns(:health_check_template) { eq health_check_template }

        it "sets user in import" do
          call_action
          expect(HealthCheckImport.last.user).to eq(user)
        end

        it "sets account in import" do
          call_action
          expect(HealthCheckImport.last.account).to eq(account)
        end

        it_ignores_attributes :site_id => 0, :account_id => 0, :user_id => 0, :on => :health_check_import, :record => "HealthCheckImport.last"
        it_permits_attributes :csv_data => "www.google.com", :on => :health_check_import, :record => "HealthCheckImport.last"
      end

      context "for site" do
        let(:csv) { [
          ['www.google.com'].to_csv,
          ['www.wikipedia.org'].to_csv
        ].join }

        before { params.merge!(:account_id => account.id, :site_id => site.permalink, :health_check_import => { :health_check_template_id => health_check_template.id, :csv_data => csv }) }

        it_requires_params :account_id, :site_id

        context "given valid parameters" do
          it_changes("health check count") { HealthCheck.count }
          it_shows_flash
          it_does_not_assign :preview
          it_redirects

          it "sets site in import" do
            call_action
            expect(HealthCheckImport.last.site).to eq(site)
          end
        end

        context "given invalid parameters" do
          before { params[:health_check_import].merge!(:csv_data => nil) }

          it_does_not_change("health check count") { HealthCheck.count }
          it_returns_success
          it_renders :new
          it_does_not_assign :preview
        end
      end

      context "for account" do
        let(:csv) { [
          ['first_site', 'Google', 'http://www.google.com'].to_csv,
          ['second_site', 'Wikipedia', 'http://www.wikipedia.org'].to_csv
        ].join }

        before { params.merge!(:health_check_import => { :health_check_template_id => health_check_template.id, :csv_data => csv }) }

        context "given valid parameters" do
          it_changes("site count") { Site.count }
          it_changes("health check count") { HealthCheck.count }
          it_redirects
          it_shows_flash
          it_does_not_assign :preview
        end

        context "given invalid parameters" do
          before { params[:health_check_import].merge!(:csv_data => nil) }

          it_does_not_change("site count") { Site.count }
          it_does_not_change("health check count") { HealthCheck.count }
          it_returns_success
          it_renders :new
          it_does_not_assign :preview
        end
      end
    end
  end

  describe "#destroy" do
    context "for site" do
      let(:import) { create(:site_health_check_import, :user => user, :account => account, :site => site, :health_check_template => health_check_template) }
      before { params.merge!(:account_id => account.id, :site_id => site.permalink, :id => import.id) }

      it_requires_params :account_id, :site_id
      it_changes("import count") { HealthCheckImport.count }
      it_changes("health check count") { HealthCheck.count }
      it_shows_flash
      it_redirects
    end

    context "for account" do
      let(:import) { create(:account_health_check_import, :user => user, :account => account, :health_check_template => health_check_template) }
      before { params.merge!(:id => import.id) }

      it_changes("import count") { HealthCheckImport.count }
      it_changes("health check count") { HealthCheck.count }
      it_does_not_change("site count") { Site.count }
      it_redirects
    end
  end
end
