require 'spec_helper'

describe PasswordResetsController do
  let(:user) { create(:user) }

  let(:params) { { :locale => 'en' } }

  before { user; logout }

  describe "#index" do
    it_returns_success
  end

  describe "#new" do
    it_returns_success
  end

  describe "#create" do
    before { params.merge!(:email => user.email) }

    context "given valid email" do
      it_redirects
      it_shows_flash
    end

    context "given invalid email" do
      before { params.merge!(:email => 'foobar.com') }

      it_returns_success
      it_renders :new
      it_shows_error
    end
  end

  describe "#edit" do
    context "given valid token" do
      # the logout call in the setup method resets the perishable token, so we have to reload the user
      before { params.merge!(:id => user.reload.perishable_token) }

      it_returns_success
      it_shows_no_error
    end

    context "given invalid perishable token" do
      before { params.merge!(:id => "foo") }

      it_shows_error
    end
  end

  describe "#update" do
    context "given valid parameters" do
      before { params.merge!(:id => user.reload.perishable_token, :user => { :password => '54321', :password_confirmation => '54321' }) }

      it_redirects
      it_shows_flash

      it "makes new password valid" do
        call_action
        expect(user.reload.valid_password?('54321')).to be_true
      end

      it "makes old password invalid" do
        call_action
        expect(user.reload.valid_password?('12345')).to be_false
      end
    end

    context "given invalid parameters" do
      before { params.merge!(:id => user.reload.perishable_token, :user => { :password => 'a', :password_confirmation => 'a' }) }

      it_returns_success
      it_renders :edit
      it_shows_no_flash

      it "does not make new password valid" do
        call_action
        expect(user.reload.valid_password?('a')).to be_false
      end

      it "keeps old password valid" do
        call_action
        expect(user.reload.valid_password?('12345')).to be_true
      end
    end

    context "given invalid perishable token" do
      before { params.merge!(:id => 'foo', :user => { :password => '54321', :password_confirmation => '54321' }) }

      it_redirects
      it_shows_error

      it "does not make new password valid" do
        call_action
        expect(user.reload.valid_password?('54321')).to be_false
      end

      it "keeps old password valid" do
        call_action
        expect(user.reload.valid_password?('12345')).to be_true
      end
    end
  end
end
