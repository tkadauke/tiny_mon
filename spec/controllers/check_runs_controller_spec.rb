require 'spec_helper'

describe CheckRunsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:site) { create(:site, :account => account) }
  let(:health_check) { create(:health_check, :site => site) }
  let(:check_run) { create(:check_run, :health_check => health_check) }

  let(:params) { { :locale => 'en', :account_id => account, :site_id => site.to_param, :health_check_id => health_check.to_param } }
  let(:json) { JSON.parse(response.body) }

  before { login_with user }

  it_requires_login

  describe "#index" do
    before { @check_runs = create_list(:check_run, 5, :health_check => health_check) }

    it_requires_params :account_id, :site_id, :health_check_id

    context "called normally" do
      it_returns_success

      it "assigns check runs" do
        call_action
        expect(assigns(:check_runs).to_a.sort_by(&:id)).to eq(@check_runs.sort_by(&:id))
      end

      it_paginates :check_runs

      context "with filter" do
        before do
          yesterday = Date.yesterday
          tomorrow = Date.tomorrow

          params.merge!(
            :check_run_filter => { 
              "start_date(1i)" => yesterday.year, "start_date(2i)" => yesterday.month, "start_date(3i)" => yesterday.day,
              "end_date(1i)"   => tomorrow.year,  "end_date(2i)"   => tomorrow.month,  "end_date(3i)" => tomorrow.day
            }
          )

          create_list(:check_run, 3, :health_check => health_check, :created_at => 3.days.ago)
        end

        it "returns only check runs that fall in the date range" do
          call_action
          expect(assigns(:check_runs)).to have(@check_runs.size).items
        end
      end

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it "returns check runs" do
          call_action
          expect(json).to have(@check_runs.size).items
        end
      end
    end

    context "called as XHR" do
      it_returns_success
      it_renders "check_runs/_activity"
    end
  end

  describe "#recent" do
    let(:params) { { :locale => 'en', :format => 'json' } }
    before { create_list(:check_run, 5, :health_check => health_check) }

    it "returns recent check runs" do
      call_action
      expect(json).to have(5).items
    end

    it "includes health checks" do
      call_action
      expect(json.first).to have_key("health_check")
    end
  end

  describe "#show" do
    before { params.merge!(:id => check_run) }

    it_requires_params :account_id, :site_id, :health_check_id, :id
    it_assigns(:check_run) { be_a(CheckRun) }

    describe "comments" do
      before { @comments = create_list(:comment, 3, :check_run => check_run, :user => user) }

      it_assigns(:comment) { be_new_record }
      it_assigns(:comments_count) { eq @comments.size }

      it "assigns existing comments" do
        call_action
        expect(assigns(:comments).to_a.sort_by(&:id)).to eq(@comments.sort_by(&:id))
      end
    end

    describe "screenshots" do
      before { @screenshots = create_list(:screenshot, 3, :check_run => check_run) }

      it_assigns(:screenshots) { eq @screenshots }
    end

    context "called normally" do
      it_returns_success

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it_returns_success

        it "return JSON for check run" do
          call_action
          expect(json['id']).to eq(check_run.id)
        end
      end
    end

    context "called as XHR" do
      it_returns_success
      it_renders "check_runs/_details"
    end
  end

  describe "#create" do
    it_requires_params :account_id, :site_id, :health_check_id

    context "given user can run health checks" do
      it "creates check run" do
        expect { call_action }.to change { CheckRun.count }
      end

      it_redirects

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it "returns new check run" do
          call_action
          expect(json['id']).to eq(CheckRun.last.id)
        end
      end
    end

    context "given user cannot run health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end
end
