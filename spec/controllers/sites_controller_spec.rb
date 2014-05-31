require 'spec_helper'

describe SitesController do
  let(:account) { create(:account) }
  let(:user) { create(:user, :account_admin, :current_account => account) }
  let(:site) { create(:site, :account => account) }

  let(:params) { { :locale => 'en', :account_id => account } }
  let(:json) { JSON.parse(response.body) }

  before { login_with user }

  it_requires_login

  describe "#index" do
    before { @sites = create_list(:site, 5, :account => account) }

    it_requires_params :account_id
    it_returns_success
    it_assigns(:search_filter) { be_a SearchFilter }
    it_assigns(:sites) { include @sites.sample }

    context "given a search filter" do
      before { params.merge!(:search_filter => { :query => 'foobar' }) }
      before { @other_site = create(:site, :name => 'foobar', :account => account) }

      it_assigns(:sites) { include @other_site }
    end

    context "with JSON format" do
      before { params.merge!(:format => 'json') }

      it "returns sites" do
        call_action
        expect(json).to have(@sites.size).items
      end
    end
  end

  describe "#new" do
    it_requires_params :account_id

    context "given user can create sites" do
      it_returns_success
      it_assigns(:site) { be_new_record }
    end

    context "given user cannot create sites" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#create" do
    before { params.merge!(:site => { :name => 'example.com', :url => 'http://www.example.com' }) }

    it_requires_params :account_id

    context "given user can create sites" do
      context "given valid parameters" do
        it_changes("site count") { Site.count }
        it_shows_flash
        it_redirects

        context "with JSON format" do
          before { params.merge!(:format => 'json') }

          it_changes("site count") { Site.count }

          it "returns new site" do
            call_action
            expect(json['id']).to eq(Site.last.id)
          end
        end
      end

      context "given invalid parameters" do
        before { params[:site].merge!(:url => nil) }

        it_does_not_change("site count") { Site.count }
        it_returns_success
        it_assigns(:site) { be_new_record }
        it_renders :new
      end

      it_ignores_attributes :account_id => 0, :permalink => 'foo', :deployment_token => "12345",
                            :on => :site, :record => "Site.last"
      it_permits_attributes :name => "some name", :url => "http://some.url",
                            :on => :site, :record => "Site.last"
    end

    context "given user cannot create sites" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#show" do
    before { params.merge!(:id => site.to_param) }

    it_requires_params :account_id, :id
    it_returns_success
    it_assigns(:site) { eq site }

    context "with JSON format" do
      before { params.merge!(:format => 'json') }

      it "returns site" do
        call_action
        expect(json['id']).to eq(site.id)
      end
    end
  end

  describe "#edit" do
    before { params.merge!(:id => site.to_param) }

    it_requires_params :account_id, :id

    context "given user can edit sites" do
      it_returns_success
      it_assigns(:site) { eq site }
    end

    context "given user cannot edit sites" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#update" do
    before { params.merge!(:id => site.to_param, :site => { :name => 'something.com' }) }

    it_requires_params :account_id, :id

    context "given user can edit sites" do
      context "given valid parameters" do
        it_changes("site") { site.reload.name }
        it_redirects
        it_shows_flash

        context "with JSON format" do
          before { params.merge!(:format => 'json') }

          it_changes("site") { site.reload.name }

          it "returns updated site" do
            call_action
            expect(json['id']).to eq(site.id)
          end
        end
      end

      context "given invalid parameters" do
        before { params[:site].merge!(:url => nil) }

        it_does_not_change("site") { site.reload }
        it_returns_success
      end

      it_ignores_attributes :account_id => 0, :permalink => 'foo', :deployment_token => "12345",
                            :on => :site
      it_permits_attributes :name => "some name", :url => "http://some.url",
                            :on => :site
    end

    context "given user cannot edit sites" do
      before { demote(user, account) }

      it_shows_error
    end
  end

  describe "#destroy" do
    before { params.merge!(:id => site.to_param) }

    it_requires_params :account_id, :id

    context "given user can delete sites" do
      it_changes("site count") { Site.count }
      it_redirects
      it_shows_flash

      context "with JSON format" do
        before { params.merge!(:format => 'json') }

        it_changes("site count") { Site.count }

        it "returns nothing" do
          call_action
          expect(response.body).to be_blank
        end
      end
    end

    context "given user cannot delete sites" do
      before { demote(user, account) }

      it_shows_error
    end
  end
end