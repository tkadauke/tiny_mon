require 'spec_helper'

describe HealthChecksController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:site) { create(:site, :account => account) }
  let(:health_check) { create(:health_check, :site => site) }

  let(:params) { { :locale => 'en', :account_id => account } }
  let(:json) { JSON.parse(response.body) }

  before { login_with user }

  it_requires_login

  describe "#index" do
    before { @health_checks = create_list(:health_check, 5, :site => site) }

    it_requires_params :account_id

    context "with report parameter" do
      before { params.merge!(:report => 'overview') }

      it_assigns(:report) { eq params[:report] }

      it "stores setting" do
        call_action
        expect(user.soft_settings.get("health_checks.report")).to eq('overview')
      end
    end

    context "with status filter" do
      before { params.merge!(:status => 'success') }

      it_assigns(:status) { eq params[:status] }

      it "stores setting" do
        call_action
        expect(user.soft_settings.get("health_checks.status")).to eq('success')
      end
    end

    context "with search filter" do
      before { params.merge!(:search_filter => { :query => 'Home' }) }

      it_assigns(:search_filter) { be_a SearchFilter }
      it_returns_success
    end

    context "with site parameter" do
      before { params.merge!(:site_id => site.to_param) }

      it_requires_params :account_id, :site_id
      it_returns_success
      it_renders :index
      it_assigns(:health_checks) { include @health_checks.sample }

      context "called as XHR" do
        it_returns_success
      end

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it "returns health checks" do
          call_action
          expect(json).to have(@health_checks.size).items
        end
      end
    end

    context "without site parameter" do
      it_returns_success
      it_assigns(:health_checks) { eq @health_checks }
      it_renders :all_checks

      context "called as XHR" do
        it_returns_success
        it_renders "health_checks/index"
      end

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it "returns health checks" do
          call_action
          expect(json).to have(@health_checks.size).items
        end
      end
    end
  end

  describe "#upcoming" do
    let(:params) { { :locale => 'en', :format => 'json' } }
    before { create_list(:health_check, 5, :site => site, :next_check_at => 5.minutes.from_now) }

    it "returns upcoming health checks" do
      call_action
      expect(json).to have(5).items
    end

    it "includes sites" do
      call_action
      expect(json.first).to have_key("site")
    end
  end

  describe "#new" do
    before { params.merge!(:site_id => site.to_param) }

    it_requires_params :account_id, :site_id

    context "given user can create health checks" do
      it_returns_success
      it_assigns(:health_check) { be_new_record }
    end

    context "given user cannot create health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#create" do
    before { params.merge!(:site_id => site.to_param, :health_check => { :name => 'Login', :interval => 1 }) }

    it_requires_params :account_id, :site_id

    context "given user can create health checks" do
      context "given valid parameters" do
        it_changes("health check count") { HealthCheck.count }
        it_redirects
        it_shows_flash
        it_assigns(:health_check) { eq HealthCheck.last }

        it_ignores_attributes :site_id => 0, :status => 'success', :permalink => 'hello',
                              :last_checked_at => Time.now, :next_check_at => Time.now,
                              :health_check_import_id => 0, :weather => 7,
                              :on => :health_check, :record => 'HealthCheck.last'
        it_permits_attributes :enabled => true, :name => "hello", :description => "world", :interval => 5,
                              :on => :health_check, :record => 'HealthCheck.last'

        context "given a template" do
          let(:template) { create(:health_check_template, :account => account, :user => user) }
          before do
            params.merge!(:template => template)
            params[:health_check].merge!(:template_data => { :domain => 'www.google.com' })
          end

          it "creates from template" do
            call_action
            expect(HealthCheck.last.name).to eq("Visit www.google.com")
          end

          it_changes("step count") { Step.count }
          it_assigns(:health_check_template) { eq template }

          context "and previewing" do
            before { params.merge!(:commit => 'Preview') }

            it_assigns(:preview) { be_true }
            it_renders :new
          end
        end

        context "with JSON format" do
          before { params.merge!(:format => 'json') }

          it_changes("health check count") { HealthCheck.count }

          it "returns new health check" do
            call_action
            expect(json['id']).to eq(HealthCheck.last.id)
          end
        end
      end

      context "given invalid parameters" do
        before { params[:health_check].merge!(:name => nil) }

        it_does_not_change("health check count") { HealthCheck.count }
        it_returns_success
        it_renders :new
      end

      it_ignores_attributes :site_id => 0, :status => 'failed', :permalink => "foobarbaz",
                            :last_checked_at => 1.day.ago, :next_check_at => 1.day.from_now,
                            :health_check_import_id => 0, :weather => 5,
                            :on => :health_check, :record => "HealthCheck.last"
      it_permits_attributes :enabled => true, :name => "some name", :description => "some description",
                            :interval => 60,
                            :on => :health_check, :record => "HealthCheck.last"
    end

    context "given user cannot create health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#show" do
    before { params.merge!(:site_id => site.to_param, :id => health_check.to_param) }

    it_requires_params :account_id, :site_id, :id
    it_returns_success
    it_assigns(:health_check) { eq health_check }

    describe "comments" do
      before { @comments = create_list(:comment, 6, :user => user, :check_run => create(:check_run, :health_check => health_check)) }

      it "assigns comments" do
        call_action
        expect(@comments).to include(assigns(:comments).first)
      end

      it_assigns(:comments) { have(5).items }
      it_assigns(:comments_count) { eq @comments.size }
    end

    context "with JSON format" do
      before { params.merge!(:format => 'json') }

      it "returns health check" do
        call_action
        expect(json['id']).to eq(health_check.id)
      end
    end
  end

  describe "#edit" do
    before { params.merge!(:site_id => site.to_param, :id => health_check.to_param) }

    it_requires_params :account_id, :site_id, :id

    context "given user can edit health checks" do
      it_returns_success
      it_assigns(:health_check) { eq health_check }
    end

    context "given user cannot edit health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#update" do
    before { params.merge!(:site_id => site.to_param, :id => health_check.to_param, :health_check => { :name => 'Login' }) }

    it_requires_params :account_id, :site_id, :id

    context "given user can update health checks" do
      context "given valid parameters" do
        it_changes("health check") { health_check.reload.name }
        it_redirects
        it_shows_flash

        context "with JSON format" do
          before { params.merge!(:format => 'json') }

          it_changes("health check") { health_check.reload.name }

          it "returns updated health check" do
            call_action
            expect(json['id']).to eq(health_check.id)
          end
        end
      end

      context "given invalid parameters" do
        before { params[:health_check].merge!(:name => nil) }

        it_does_not_change("health check") { health_check.reload }
        it_returns_success
      end

      it_ignores_attributes :site_id => 0, :status => 'failed', :permalink => "foobarbaz",
                            :last_checked_at => 1.day.ago, :next_check_at => 1.day.from_now,
                            :health_check_import_id => 0, :weather => 5, :on => :health_check
      it_permits_attributes :enabled => true, :name => "some name", :description => "some description",
                            :interval => 60, :on => :health_check
    end

    context "given user cannot edit health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#edit_multiple" do
    let(:health_check1) { create(:health_check, :site => site, :name => 'Home page', :interval => 1) }
    let(:health_check2) { create(:health_check, :site => site, :name => 'About page', :interval => 1) }
    let(:params) { { :locale => 'en', :health_check_ids => [health_check1.id, health_check2.id] } }

    context "given IDs" do
      context "given user can create health checks" do
        it_returns_success

        it "assigns health checks" do
          call_action
          expect(assigns(:health_checks).to_a.sort_by(&:id)).to eq([health_check1, health_check2].to_a.sort_by(&:id))
        end
      end

      context "given user cannot create health checks" do
        before { demote(user, account) }

        it_shows_error
      end
    end

    context "given IDs from wrong account" do
      let(:wrong_account) { create(:account) }
      let(:wrong_site) { create(:site, :account => wrong_account) }
      let(:wrong_health_check) { create(:health_check, :site => wrong_site) }

      before { params[:health_check_ids] << wrong_health_check.id }

      it "raises error" do
        expect { call_action }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "given no IDs" do
      before { params.merge!(:health_check_ids => []) }

      it_redirects_back
    end
  end

  describe "#update_multiple" do
    let(:health_check1) { create(:health_check, :site => site, :name => 'Home page', :interval => 1) }
    let(:health_check2) { create(:health_check, :site => site, :name => 'About page', :interval => 1) }
    let(:params) { { :locale => 'en', :health_check_ids => [health_check1.id, health_check2.id], :health_check => { :bulk_update_interval => '1', :interval => 60 } } }

    context "given user can create health checks" do
      it "updates health checks" do
        call_action
        expect(health_check1.reload.interval).to eq(60)
        expect(health_check2.reload.interval).to eq(60)
      end

      it "assigns health checks" do
        call_action
        expect(assigns(:health_checks).to_a.sort_by(&:id)).to eq([health_check1, health_check2].to_a.sort_by(&:id))
      end

      it_redirects
      it_shows_flash

      context "with unselected field" do
        let(:params) { { :locale => 'en', :health_check_ids => [health_check1.id, health_check2.id], :health_check => { :bulk_update_interval => '0', :interval => 1 } } }

        it "does not update" do
          call_action
          expect(health_check1.reload.interval).to eq(1)
          expect(health_check2.reload.interval).to eq(1)
        end
      end

      { :name => "foo", :enabled => true, :description => "hello" }.each do |attribute, value|
        it "bulk updates #{attribute}" do
          params[:health_check].merge!(:"bulk_update_#{attribute}" => '1', attribute => value)
          call_action
          expect(health_check1.reload.send(attribute)).to eq(value)
          expect(health_check2.reload.send(attribute)).to eq(value)
        end
      end

      context "given IDs from wrong account" do
        let(:wrong_account) { create(:account) }
        let(:wrong_site) { create(:site, :account => wrong_account) }
        let(:wrong_health_check) { create(:health_check, :site => wrong_site) }

        before { params[:health_check_ids] << wrong_health_check.id }

        it "raises error" do
          expect { call_action }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "given user cannot create health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#destroy" do
    before { params.merge!(:site_id => site.to_param, :id => health_check.to_param) }

    it_requires_params :account_id, :site_id, :id

    context "given user can update health checks" do
      it_changes("health check count") { HealthCheck.count }
      it_redirects
      it_shows_flash

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it_changes("health check count") { HealthCheck.count }
        it_returns_nothing
      end
    end

    context "given user cannot update health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end
end
