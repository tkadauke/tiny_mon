require 'spec_helper'

describe ApplicationController do
  controller do
    respond_to :html, :json

    before_filter :login_required, :only => :user_only_action
    before_filter :guest_required, :only => :guest_only_action
    before_filter :can_win!, :only => :admin_only_action

    def guest_only_action
      render :text => 'foo'
    end
    def user_only_action
      render :text => 'foo'
    end
    def admin_only_action
      can_win! do
        render :text => 'foo'
      end
    end
  end

  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }

  before do
    routes.draw do
      %w(guest_only_action user_only_action admin_only_action).each do |action|
        get action => "anonymous##{action}"
      end
    end
  end

  describe "access control" do
    let(:params) { { :locale => 'en' } }

    context "given regular user is logged in" do
      before { login_with user }

      context "and accesses a user only action" do
        it "returns success" do
          get :user_only_action, params
          expect(response).to be_success
        end
      end

      context "and accesses a guest only action" do
        it "redirects" do
          get :guest_only_action, params
          expect(response).to be_redirect
        end

        it "shows error" do
          get :guest_only_action, params
          expect(flash[:error]).not_to be_nil
        end

        context "with json format" do
          before { params.merge!(:format => :json) }

          it "returns unauthorized status" do
            get :guest_only_action, params
            expect(response.response_code).to eq(401)
          end
        end
      end

      context "and accesses an admin only action" do
        it "redirects" do
          get :admin_only_action, params
          expect(response).to be_redirect
        end

        it "shows error" do
          get :admin_only_action, params
          expect(flash[:error]).not_to be_nil
        end

        context "with json format" do
          before { params.merge!(:format => :json) }

          it "returns unauthorized status" do
            get :admin_only_action, params
            expect(response.response_code).to eq(401)
          end
        end
      end
    end

    context "given user is logged out" do
      context "and accesses guest only action" do
        it "returns success" do
          get :guest_only_action, params
          expect(response).to be_success
        end
      end

      context "and accesses user only action" do
        it "redirects" do
          get :user_only_action, params
          expect(response).to be_redirect
        end

        it "shows error" do
          get :user_only_action, params
          expect(flash[:error]).not_to be_nil
        end

        context "with json format" do
          before { params.merge!(:format => :json) }

          it "returns unauthorized status" do
            get :user_only_action, params
            expect(response.code).to eq("401")
          end
        end
      end
    end
  end

  describe "language" do
    before { I18n.locale = :fr }
    after { I18n.locale = :en }

    context "given locale parameter is given" do
      let(:params) { { :locale => :de } }

      it "sets the locale to the given locale" do
        get :guest_only_action, params
        expect(I18n.locale).to eq(params[:locale])
      end

      it "does no language redirect" do
        get :guest_only_action, params
        expect(response).to be_success
      end
    end

    context "given locale parameter is not given" do
      context "and user has set a language" do
        before do
          login_with user
          user.config.update_attributes(:language => 'de')
        end

        it "redirects to the user's language" do
          get :user_only_action
          expect(response).to redirect_to(/locale=de/)
        end
      end

      context "and the user has set no language" do
        it "redirects to the default language" do
          get :guest_only_action
          expect(response).to redirect_to(/locale=#{TinyMon::Config.language}/)
        end
      end
    end
  end
end
