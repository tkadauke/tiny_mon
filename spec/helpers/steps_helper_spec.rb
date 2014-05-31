require 'spec_helper'

describe StepsHelper do
  before do
    controller.singleton_class.class_eval do
      def default_url_options(options = {})
        { :locale => 'en' }
      end
    end
  end

  describe "#render_step_form" do
    let(:health_check) { create(:health_check) }
    let(:site) { health_check.site }
    let(:account) { site.account }

    context "for Step instance" do
      let(:instance) { Step.new }

      it "returns nil" do
        helper.form_for instance, :url => account_site_health_check_steps_path(account, site, health_check) do |form|
          expect(helper.render_step_form(form, instance)).to be_nil
        end
      end
    end

    Step.available_types.each do |type|
      klass = "#{type}_step".classify.constantize
      context "for #{klass} instance" do
        let(:instance) { klass.new }

        it "renders form" do
          helper.form_for instance, :url => account_site_health_check_steps_path(account, site, health_check) do |form|
            expect(helper.render_step_form(form, instance)).not_to be_nil
          end
        end
      end
    end
  end

  describe "#render_step_details" do
    Step.available_types.each do |type|
      klass = "#{type}_step".classify.constantize
      context "for #{klass} instance" do
        let(:instance) { klass.new }

        it "renders details" do
          expect(helper.render_step_details(instance)).not_to be_nil
        end
      end
    end
  end
end
