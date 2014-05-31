require 'spec_helper'

describe Admin::UsersController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :admin, :current_account => account) }

  let(:params) { { :locale => 'en' } }

  before { login_with user }

  it_requires_login
  it_requires_admin

  describe "#index" do
    before { @users = create_list(:user, 5) }

    it_returns_success
    it_assigns(:search_filter) { be_a SearchFilter }
    it_assigns(:users) { include @users.first }
    it_paginates(:users)

    context "given a search filter" do
      before { params.merge!(:search_filter => { :query => 'Test' }) }
      before { @other_user = create(:user, :full_name => 'Test User') }

      it_assigns(:users) { include @other_user }
    end
  end
end
