require 'spec_helper'

describe ApplicationHelper do
  before do
    controller.singleton_class.class_eval do
      def current_user
        @current_user ||= FactoryGirl.create(:user)
      end
      helper_method :current_user

      def logged_in?
        @logged_in
      end
      helper_method :logged_in?

      def default_url_options(options = {})
        { :locale => 'en' }
      end

      attr_writer :logged_in
    end
  end

  describe "#title" do
    it "sets content for page title" do
      helper.title("hello")
      expect(helper.content_for(:page_title)).to eq("hello")
    end
  end

  describe "#gravatar" do
    let(:user) { create(:user) }

    it "contains text if present" do
      result = helper.gravatar(user, :text => "my profile")
      expect(result).to match("my profile")
    end

    it "contains size if present" do
      result = helper.gravatar(user, :size => 45)
      expect(result).to match("45x45")
    end

    it "defaults to size 50x50" do
      result = helper.gravatar(user)
      expect(result).to match("50x50")
    end

    it "contains link to user profile" do
      result = helper.gravatar(user)
      expect(result).to match("users/#{user.id}")
    end

    it "contains gravatar's image" do
      result = helper.gravatar(user)
      expect(result).to match("gravatar.com/avatar")
    end
  end

  describe "#poll" do
    it "uses specifed element" do
      result = helper.poll("/foo", :element => "some_element")
      expect(result).to match("some_element")
    end

    it "defaults to element 'list'" do
      result = helper.poll("/foo")
      expect(result).to match("list")
    end

    it "uses specified interval" do
      result = helper.poll("/foo", :interval => 25)
      expect(result).to match("25000")
    end

    it "defaults to interval 10" do
      result = helper.poll("/foo")
      expect(result).to match("10000")
    end

    it "uses specified URL" do
      result = helper.poll("/foo")
      expect(result).to match("/foo")
    end
  end

  describe "#bread_crumb" do
    before { allow(helper).to receive(:request).and_return(double(:fullpath => "/en/foo/bar/baz")) }

    it "contains list items" do
      expect(helper.bread_crumb).to match("<li>")
    end

    it "contains dividers" do
      expect(helper.bread_crumb).to match("divider")
    end

    it "contains a highlight" do
      expect(helper.bread_crumb).to match("<strong>")
    end

    context "with simple path" do
      before { allow(helper).to receive(:request).and_return(double(:fullpath => "/en/settings")) }

      it "contains '/en' link" do
        expect(helper.bread_crumb).to match(%{<a href="/en">})
      end

      it "contains '/en/settings' highlight" do
        expect(helper.bread_crumb).to match(%{<strong>Settings</strong>})
      end
    end

    context "with one model" do
      let(:account) { create(:account) }
      before { allow(helper).to receive(:request).and_return(double(:fullpath => "/en/accounts/#{account.id}/sites")) }

      it "contains '/en/accounts' link" do
        expect(helper.bread_crumb).to match(%{<a href="/en/accounts">})
      end

      it "contains '/en/accounts/x' link" do
        expect(helper.bread_crumb).to match(%{<a href="/en/accounts/#{account.id}">})
      end

      it "contains account name" do
        expect(helper.bread_crumb).to match(account.name)
      end

      it "contains '/en/settings/x/sites' highlight" do
        expect(helper.bread_crumb).to match(%{<strong>Sites</strong>})
      end
    end

    context "with nested models" do
      let(:account) { create(:account) }
      let(:site) { create(:site, :account => account) }
      let(:health_check) { create(:health_check, :site => site) }
      let(:check_run) { create(:check_run, :health_check => health_check) }
      before { allow(helper).to receive(:request).and_return(double(:fullpath => "/en/accounts/#{account.id}/sites/#{site.permalink}/health_checks/#{health_check.permalink}/check_runs/#{check_run.id}")) }

      it "recognizes site from URL component" do
        expect(helper.bread_crumb).to match(site.name)
      end

      it "recognizes health check from URL component" do
        expect(helper.bread_crumb).to match(health_check.name)
      end

      it "contains check run highlight" do
        expect(helper.bread_crumb).to match(%{<strong>#{check_run.id}</strong>})
      end
    end
  end

  describe "status_icon" do
    context "given model is blank" do
      it "returns nil" do
        expect(helper.status_icon(nil)).to be_nil
      end
    end

    context "given model is present" do
      it "returns status icon" do
        expect(helper.status_icon(build(:health_check))).to match("</i>")
      end
    end
  end

  describe "status_class" do
    context "given model is blank" do
      it "returns nil" do
        expect(helper.status_class(nil)).to be_nil
      end
    end

    context "given model is disabled" do
      it "returns 'warning'" do
        expect(helper.status_class(build(:health_check, :enabled => false))).to eq("warning")
      end
    end

    context "given model has success status" do
      it "returns 'success'" do
        expect(helper.status_class(build(:health_check, :status => "success"))).to eq("success")
      end
    end

    context "given model has failure status" do
      it "returns 'danger'" do
        expect(helper.status_class(build(:health_check, :status => "failure"))).to eq("danger")
      end
    end

    context "given model has no status" do
      it "returns 'warning'" do
        expect(helper.status_class(build(:health_check, :status => nil))).to eq("warning")
      end
    end
  end

  describe "status_background" do
    context "given model is disabled" do
      it "returns 'yellow'" do
        expect(helper.status_background(build(:health_check, :enabled => false))).to eq("yellow")
      end
    end

    context "given model has success status" do
      it "returns 'green'" do
        expect(helper.status_background(build(:health_check, :status => "success"))).to eq("green")
      end
    end

    context "given model has failure status" do
      it "returns 'red'" do
        expect(helper.status_background(build(:health_check, :status => "failure"))).to eq("red")
      end
    end

    context "given model has no status" do
      it "returns 'yellow'" do
        expect(helper.status_background(build(:health_check, :status => nil))).to eq("yellow")
      end
    end

    context "given model has offline status" do
      it "returns 'yellow'" do
        expect(helper.status_background(build(:site))).to eq("yellow")
      end
    end
  end

  describe "status_icon_class" do
    context "given model is disabled" do
      it "returns 'warning'" do
        expect(helper.status_icon_class(build(:health_check, :enabled => false))).to eq("warning")
      end
    end

    context "given model has offline status" do
      it "returns 'warning'" do
        expect(helper.status_icon_class(build(:site))).to eq("warning")
      end
    end

    context "given model has success status" do
      it "returns 'check'" do
        expect(helper.status_icon_class(build(:health_check, :status => "success"))).to eq("check")
      end
    end

    context "given model has failure status" do
      it "returns 'exclamation'" do
        expect(helper.status_icon_class(build(:health_check, :status => "failure"))).to eq("exclamation")
      end
    end

    context "given model has no status" do
      it "returns 'spinner'" do
        expect(helper.status_icon_class(build(:health_check, :status => nil))).to eq("spinner")
      end
    end
  end

  describe "#overall_status" do
    context "given no model" do
      it "returns nil" do
        expect(helper.overall_status(nil)).to be_nil
      end
    end

    context "for deployment" do
      let(:health_check) { create(:health_check) }
      before { @deployment = create(:deployment, :site => health_check.site) }

      context "given all check runs are successful" do
        before { create(:check_run, :status => 'success', :health_check => health_check) }

        it "returns success icon" do
          expect(helper.overall_status(@deployment)).to match("bg-green")
        end
      end

      context "given not all check runs are successful" do
        before { create(:check_run, :status => 'failure', :health_check => health_check) }

        it "returns failure icon" do
          expect(helper.overall_status(@deployment)).to match("bg-red")
        end
      end
    end

    context "for site" do
      let(:health_check) { create(:health_check) }
      let(:site) { health_check.site }

      context "given all check runs are successful" do
        # health check status update is only triggered on check run update
        before { create(:check_run, :status => 'success', :health_check => health_check).save }

        it "returns success icon" do
          expect(helper.overall_status(site)).to match("bg-green")
        end
      end

      context "given not all check runs are successful" do
        before { create(:check_run, :status => 'failure', :health_check => health_check).save }

        it "returns failure icon" do
          expect(helper.overall_status(site)).to match("bg-red")
        end
      end
    end

    context "for account" do
      let(:health_check) { create(:health_check) }
      let(:account) { health_check.site.account }

      context "given all check runs are successful" do
        before { create(:check_run, :status => 'success', :health_check => health_check).save }

        it "returns success icon" do
          expect(helper.overall_status(account)).to match("bg-green")
        end
      end

      context "given not all check runs are successful" do
        before { create(:check_run, :status => 'failure', :health_check => health_check).save }

        it "returns failure icon" do
          expect(helper.overall_status(account)).to match("bg-red")
        end
      end
    end
  end

  describe "#weather_icon" do
    context "given model is blank" do
      it "returns nil" do
        expect(helper.weather_icon(nil)).to be_nil
      end
    end

    context "given model's weather is blank" do
      it "returns nil" do
        expect(helper.weather_icon(build(:health_check))).to be_nil
      end
    end

    context "given model has a weather" do
      it "returns icon" do
        expect(helper.weather_icon(build(:health_check, :weather => 3))).to match("weather-icon")
      end

      it "contains number of successful within last 5 check runs" do
        expect(helper.weather_icon(build(:health_check, :weather => 3))).to match("3")
      end

      it "contains size" do
        expect(helper.weather_icon(build(:health_check, :weather => 3), :large)).to match("large")
      end
    end
  end

  describe "#revision_link" do
    context "given revision is known" do
      it "contains github link" do
        expect(helper.revision_link).to match("github.com/tkadauke/tiny_mon")
      end
    end

    context "given revision is unknown" do
      it "outputs no link" do
        expect(TinyMon::Version).to receive(:build).and_return('unknown')
        expect(helper.revision_link).not_to match("<a href")
      end
    end
  end

  describe "#show_help?" do
    it "is true by default" do
      expect(helper.show_help?).to be_true
    end

    context "given help is on" do
      before { controller.current_user.soft_settings.set("help.show", "1") }

      it "is true" do
        expect(helper.show_help?).to be_true
      end
    end

    context "given help is off" do
      before { controller.current_user.soft_settings.set("help.show", "0") }

      it "is false otherwise" do
        expect(helper.show_help?).to be_false
      end
    end
  end

  describe "#current_tutorial" do
    it "is nil by default" do
      expect(helper.current_tutorial).to be_nil
    end

    it "returns previously set tutorial" do
      controller.current_user.soft_settings.set("tutorials.current", "first_health_check")
      expect(helper.current_tutorial).to eq("first_health_check")
    end
  end

  describe "#help" do
    context "given user is logged out" do
      it "returns nil" do
        expect(helper.help).to be_nil
      end
    end

    context "given user is logged in" do
      before { controller.logged_in = true }

      context "given help is off" do
        before { controller.current_user.soft_settings.set("help.show", "0") }

        it "returns nil" do
          expect(helper.help).to be_nil
        end
      end

      context "given help is on" do
        before { controller.current_user.soft_settings.set("help.show", "1") }

        context "given tutorial is on" do
          before { controller.current_user.soft_settings.set("tutorials.current", "first_health_check") }

          it "renders tutorial" do
            expect(helper.help).to match("first health check")
          end
        end

        context "given there is help for the current controller" do
          before do
            controller.singleton_class.class_eval do
              def _prefixes
                ["start"]
              end
            end
          end

          it "renders help" do
            expect(helper.help).to match("This is your dashboard")
          end
        end

        context "given there is no help for the current controller" do
          it "returns nil" do
            expect(helper.help).to be_nil
          end
        end
      end
    end
  end

  describe "#warning_tag" do
    it "contains notice" do
      expect(helper.warning_tag("attention!", "/more/info")).to match("attention!")
    end

    it "contains URL" do
      expect(helper.warning_tag("attention!", "/more/info")).to match("/more/info")
    end
  end

  describe "#account_check_run_limit_warning_if_needed" do
    let(:account) { create(:account) }
    before { controller.current_user.update_attributes(:current_account => account) }

    context "given account is over limit in general and today" do
      before do
        allow(account).to receive(:over_maximum_check_runs_per_day?).and_return(true)
        allow(account).to receive(:over_maximum_check_runs_today?).and_return(true)
      end

      it "returns warning" do
        result = helper.account_check_run_limit_warning_if_needed
        expect(result).to match(account.maximum_check_runs_per_day.to_s)
      end
    end

    context "given account is over limit in general" do
      before do
        allow(account).to receive(:over_maximum_check_runs_per_day?).and_return(true)
        allow(account).to receive(:over_maximum_check_runs_today?).and_return(false)
      end

      it "returns warning" do
        result = helper.account_check_run_limit_warning_if_needed
        expect(result).to match(account.maximum_check_runs_per_day.to_s)
      end
    end

    context "given account is over limit today" do
      before do
        allow(account).to receive(:over_maximum_check_runs_per_day?).and_return(false)
        allow(account).to receive(:over_maximum_check_runs_today?).and_return(true)
      end

      it "returns warning" do
        result = helper.account_check_run_limit_warning_if_needed
        expect(result).to match(account.maximum_check_runs_per_day.to_s)
      end
    end

    context "given account is under limit" do
      it "returns nil" do
        result = helper.account_check_run_limit_warning_if_needed
        expect(result).to be_nil
      end
    end
  end

  describe "partial_route" do
    let(:account) { create(:account) }
    let(:site) { create(:site, :account => account) }

    it "returns named route with prefilled parameters" do
      route = helper.partial_route(:account_site_path, account)
      result = route.call(:id => site)
      expect(result).to eq(account_site_path(account, site))
    end

    it "allows for named parameters" do
      route = helper.partial_route(:account_site_path, :id => site)
      result = route.call(:account_id => account)
      expect(result).to eq(account_site_path(account, site))
    end
  end
end
