module ParamsTestHelper
  module ClassMethods
    def it_requires_params(*parameters)
      parameters.each do |parameter|
        it "requires '#{parameter}' parameter" do
          params.merge!(parameter => 0)
          expect { call_action }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    def it_requires_login
      context "given user is logged out" do
        before { logout }

        it_redirects
        it_shows_error
      end
    end

    def it_requires_admin
      context "given user is not admin" do
        before do
          user.role = nil
          user.save
        end

        it_redirects
        it_shows_error
      end
    end

    def it_redirects
      it "redirects" do
        call_action
        expect(response).to be_redirect
      end
    end

    def it_redirects_back
      before { request.env["HTTP_REFERER"] = "referer" }

      it "redirects back" do
        call_action
        expect(response).to redirect_to("referer")
      end
    end

    def it_returns_success
      it "returns success" do
        call_action
        expect(response).to be_success
      end
    end

    def it_assigns(what, &block)
      it "assigns #{what}" do
        call_action
        expect(assigns(what)).to instance_eval(&block)
      end
    end

    def it_does_not_assign(what)
      it "assigns #{what}" do
        call_action
        expect(assigns(what)).to be_nil
      end
    end

    def it_paginates(what)
      it "paginates #{what}" do
        call_action
        expect(assigns(what)).to respond_to(:per_page)
      end
    end

    def it_shows_flash
      it "shows flash" do
        call_action
        expect(flash[:notice]).not_to be_nil
      end
    end

    def it_shows_no_flash
      it "shows no flash" do
        call_action
        expect(flash[:notice]).to be_nil
      end
    end

    def it_shows_error
      it "shows error" do
        call_action
        expect(flash[:error]).not_to be_nil
      end
    end

    def it_shows_no_error
      it "shows no error" do
        call_action
        expect(flash[:error]).to be_nil
      end
    end

    def it_renders(template)
      it "renders '#{template}'" do
        call_action
        expect(response).to render_template(template)
      end
    end

    def it_returns_nothing
      it "returns nothing" do
        call_action
        expect(response.body).to be_blank
      end
    end

    def it_changes(what, &block)
      it "changes #{what}" do
        expect { call_action }.to change { instance_eval(&block) }
      end
    end

    def it_does_not_change(what, &block)
      it "does not change #{what}" do
        expect { call_action }.not_to change { instance_eval(&block) }
      end
    end

    def it_ignores_attributes(attrs)
      on = attrs.delete(:on)
      record = attrs.delete(:record) || on

      context "given forbidden attributes" do
        attrs.each do |attribute, value|
          it "ignores '#{attribute}'" do
            params[on].merge!(attribute => value)
            call_action
            object = evaluate(record)
            object.reload if object.respond_to?(:reload)
            expect(object.send(attribute)).not_to eq(value)
          end
        end
      end
    end

    def it_permits_attributes(attrs)
      on = attrs.delete(:on)
      record = attrs.delete(:record) || on

      context "given permitted attributes" do
        attrs.each do |attribute, value|
          it "permits '#{attribute}'" do
            params[on].merge!(attribute => value)
            call_action
            object = evaluate(record)
            object.reload if object.respond_to?(:reload)
            expect(object.send(attribute)).to eq(value)
          end
        end
      end
    end
  end

  module InstanceMethods
    ACTION_TO_VERB = {
      # standard actions
      :index => :get,
      :show => :get,
      :new => :get,
      :create => :post,
      :edit => :get,
      :update => :post,
      :destroy => :delete,

      # custom actions
      :switch => :post,
      :recent => :get,
      :edit_multiple => :post,
      :update_multiple => :post,
      :sort => :post
    }

    def call_action
      action, xhr = current_action
      action ||= :index
      verb = ACTION_TO_VERB[action.to_sym] || (send(:verb) rescue :get)

      if xhr
        xhr verb, action, params
      else
        send(verb, action, params)
      end
    end

  protected
    def current_action
      xhr = false
      group = example.example_group
      begin
        xhr = true if group.description =~ /xhr/i
        group.description =~ /#([a-z_]+)/
        return [$1, xhr] if $1
        group = group.parent
      end while group != RSpec::Core::ExampleGroup
      [nil, xhr]
    end

    def evaluate(lambda_or_symbol_or_object)
      case lambda_or_symbol_or_object
      when Symbol
        send(lambda_or_symbol_or_object)
      when String
        eval(lambda_or_symbol_or_object)
      when Proc
        lambda_or_symbol_or_object.call
      else
        lambda_or_symbol_or_object
      end
    end
  end
end

RSpec.configure do |config|
  config.extend ParamsTestHelper::ClassMethods, type: :controller
  config.include ParamsTestHelper::InstanceMethods, type: :controller
end
