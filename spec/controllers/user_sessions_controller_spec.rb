require 'spec_helper'

describe UserSessionsController do
  let(:user) { create(:user) }

  let(:params) { { :locale => 'en' } }
  let(:json) { JSON.parse(response.body) }

  describe "#new" do
    it_returns_success
    it_assigns(:user_session) { be_a UserSession }
  end

  describe "#create" do
    before { params.merge!(:user_session => { :email => user.email, :password => '12345' }) }
    before { logout }

    context "given valid parameters" do
      it "creates user session" do
        call_action
        expect(UserSession.find.user).to eq(user)
      end

      it_shows_flash
      it_redirects

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it "creates user session" do
          call_action
          expect(UserSession.find.user).to eq(user)
        end

        it "contains user" do
          call_action
          expect(json['attempted_record']['id']).to eq(user.id)
        end

        it "contains metainfo" do
          call_action
          expect(json).to include('secure', 'httponly', 'invalid_password')
        end
      end
    end

    context "given invalid parameters" do
      before { params[:user_session].merge!(:email => 'foo@bar.com') }

      it "does not create invalid user session" do
        call_action
        expect(UserSession.find).to be_nil
      end

      it_returns_success
    end
  end

  describe "#destroy" do
    before { login_with user }

    it "destroys user session" do
      call_action
      expect(UserSession.find).to be_nil
    end

    it_shows_flash
    it_redirects

    context "with JSON format" do
      before { params.merge!(:format => 'json') }

      it "destroys user session" do
        call_action
        expect(UserSession.find).to be_nil
      end

      it_returns_nothing
    end
  end
end
