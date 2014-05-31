require 'spec_helper'

describe StepsController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:site) { create(:site, :account => account) }
  let(:health_check) { create(:health_check, :site => site) }
  let(:step) { create(:visit_step, :health_check => health_check) }

  let(:params) { { :locale => 'en', :account_id => account, :site_id => site.to_param, :health_check_id => health_check.to_param } }
  let(:json) { JSON.parse(response.body) }

  before { login_with user }

  it_requires_login

  describe "#index" do
    before { @step = create(:visit_step, :health_check => health_check) }

    it_requires_params :account_id, :site_id, :health_check_id
    it_returns_success

    it "assigns steps" do
      call_action
      expect(assigns(:steps).to_a).to eq([@step])
    end

    context "with JSON format" do
      before { params.merge!(:format => 'json') }

      it "returns steps" do
        call_action
        expect(json).to have(1).item
      end
    end
  end

  describe "#new" do
    before { params.merge!(:type => 'visit') }

    it_requires_params :account_id, :site_id, :health_check_id

    context "given user can edit health checks" do
      context "without 'clone' parameter" do
        context "called as XHR" do
          it_returns_success
          it_assigns(:step) { be_a VisitStep }
          it_renders "steps/_form"
        end
      end

      context "with 'clone' parameter" do
        before { params.merge!(:clone => step.id) }

        it_assigns(:steps) { have(2).items }
        it_renders :index
      end
    end

    context "given user cannot edit health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#edit" do
    before { params.merge!(:id => step) }

    it_requires_params :account_id, :site_id, :health_check_id, :id

    context "given user can edit health checks" do
      context "called as XHR" do
        it_returns_success
        it_assigns(:step) { eq step }
      end
    end

    context "given user cannot edit health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#create" do
    before { params.merge!(:type => 'visit', :visit_step => { :url => '/' }) }

    it_requires_params :account_id, :site_id, :health_check_id

    context "given user can edit health checks" do
      context "given valid parameters" do
        it_changes("step count") { Step.count }
        it_assigns(:step) { be_a VisitStep }
        it_redirects

        it "sets health_check in step" do
          call_action
          expect(Step.last.health_check).to eq(health_check)
        end

        context "with JSON format" do
          before { params.merge!(:format => 'json') }

          it_changes("step count") { Step.count }

          it "returns new step" do
            call_action
            expect(json['id']).to eq(Step.last.id)
          end
        end
      end

      Step.available_types.each do |step_type|
        context "given #{step_type} step" do
          step_name = "#{step_type}_step"
          step_class = step_name.classify.constantize
          properties = step_class.properties

          before do
            @example_step = create(step_name, :health_check => health_check)
            params.merge!(:type => step_type, "#{step_type}_step" => properties.inject({}) { |hash, (name, type)| hash[name] = @example_step.send(name); hash })
          end

          it "creates #{step_type} step" do
            call_action
            expect(Step.last).to be_a(step_class)
          end

          properties.each do |name, type|
            it "sets #{name}" do
              call_action
              expect(Step.last.send(name)).to eq(@example_step.send(name))
            end
          end
        end
      end

      context "given invalid parameters" do
        before { params.merge!(:visit_step => { :url => nil }) }

        it_does_not_change("step count") { Step.count }
        it_returns_success
        it_renders :index
      end
    end

    context "given user cannot edit health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#update" do
    before { params.merge!(:id => step, :visit_step => { :url => '/foo' }) }

    it_requires_params :account_id, :site_id, :health_check_id, :id

    context "given user can edit health checks" do
      it_changes("step") { step.reload.url }
      it_assigns(:step) { be_a VisitStep }
      it_redirects_back

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it_changes("step") { step.reload.url }

        it "returns updated step" do
          call_action
          expect(json['id']).to eq(step.id)
        end
      end
    end

    context "given user cannot edit health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#destroy" do
    before { params.merge!(:id => step) }

    it_requires_params :account_id, :site_id, :health_check_id, :id

    context "given user can edit health checks" do
      it_changes("step count") { Step.count }
      it_redirects_back

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it_changes("step count") { Step.count }
        it_returns_nothing
      end
    end

    context "given user cannot edit health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#sort" do
    let(:step1) { health_check.steps.create }
    let(:step2) { health_check.steps.create }
    let(:step3) { health_check.steps.create }
    before { params.merge!(:step => [step3.id, step1.id, step2.id]) }

    it_requires_params :account_id, :site_id, :health_check_id

    context "given user can edit health checks" do
      it "sorts steps" do
        call_action
        expect([step1.reload.position, step2.reload.position, step3.reload.position]).to eq([1, 2, 0])
      end

      it_returns_nothing

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it "sorts steps" do
          call_action
          expect([step1.reload.position, step2.reload.position, step3.reload.position]).to eq([1, 2, 0])
        end
      end
    end

    context "given user cannot edit health checks" do
      before { demote(user, account) }

      it_shows_error
    end
  end
end
