require 'spec_helper'

describe Account do
  let(:account) { create(:account) }
  let(:site) { create(:site, :account => account) }

  describe "#valid?" do
    it "is false by default" do
      expect(Account.new).to be_invalid
    end

    it "is true with name" do
      expect(Account.new(:name => 'foo')).to be_valid
    end
  end

  describe ".from_param!" do
    it "finds account by ID" do
      Account.from_param!(account.id).should eq(account)
    end
  end

  describe "#all_checks_successful?" do
    context "given there are no failures" do
      before { create(:health_check, :site => site, :status => 'success') }

      it "is true" do
        expect(account.all_checks_successful?).to be_true
      end
    end

    context "given there are failures" do
      before { create(:health_check, :site => site, :status => 'failure') }

      it "is false" do
        expect(account.all_checks_successful?).to be_false
      end
    end
  end

  describe "#status" do
    context "given there are no failures" do
      before { create(:health_check, :site => site, :status => 'success') }

      it "is 'success'" do
        expect(account.status).to eq('success')
      end
    end

    context "given there are failures" do
      before { create(:health_check, :site => site, :status => 'failure') }

      it "is 'failure'" do
        expect(account.status).to eq('failure')
      end
    end
  end

  describe "#user_accounts_with_users" do
    before { create_list(:user, 5, :current_account => account) }

    it "returns all users in this accounts" do
      expect(account.user_accounts_with_users).to have(5).items
    end
  end

  describe ".filter_for_list" do
    before { create(:account, :name => 'hello'); create(:account, :name => 'foobar') }

    context "given filter is empty" do
      it "returns all accounts" do
        expect(Account.filter_for_list(SearchFilter.new(:query => ""))).to have(2).items
      end
    end

    context "given filter is non-empty" do
      it "returns accounts with similar name" do
        expect(Account.filter_for_list(SearchFilter.new(:query => "foo"))).to have(1).items
      end
    end
  end

  describe "#update_check_runs_per_day" do
    it "should update check runs per day" do
      health_check1 = create(:health_check, :site => site, :interval => 60) # 24 per day
      health_check2 = create(:health_check, :site => site, :interval => 120) # 12 per day

      account.update_check_runs_per_day

      expect(account.reload.check_runs_per_day).to eq(36)
    end
  end

  describe "#unlimited_check_runs?" do
    it "is true for maximum_check_runs_per_day is set to 0" do
      expect(Account.new(:maximum_check_runs_per_day => 0).unlimited_check_runs?).to be_true
    end

    it "is false otherwise" do
      expect(Account.new.unlimited_check_runs?).to be_false
    end
  end

  describe "over_maximum_check_runs_per_day?" do
    context "given scheduled health checks are over check run limit" do
      it "is true" do
        account = Account.new(:check_runs_per_day => 50, :maximum_check_runs_per_day => 40)
        expect(account).to be_over_maximum_check_runs_per_day
      end
    end

    context "given scheduled health checks are under check run limit" do
      it "is false" do
        account = Account.new(:check_runs_per_day => 50, :maximum_check_runs_per_day => 60)
        expect(account).not_to be_over_maximum_check_runs_per_day
      end
    end

    context "given account is unlimited" do
      it "is false" do
        account = Account.new(:check_runs_per_day => 50, :maximum_check_runs_per_day => 0)
        expect(account).not_to be_over_maximum_check_runs_per_day
      end
    end
  end

  describe "over_maximum_check_runs_today?" do
    before { Account.any_instance.stubs(:scheduled_check_runs_today).returns(50) }

    context "given health checks today are over check run limit" do
      it "is true" do
        account = Account.new(:maximum_check_runs_per_day => 40)
        expect(account).to be_over_maximum_check_runs_today
      end
    end

    context "given health checks today are under check run limit" do
      it "is false" do
        account = Account.new(:maximum_check_runs_per_day => 60)
        expect(account).not_to be_over_maximum_check_runs_today
      end
    end

    context "given account is unlimited" do
      it "is false" do
        account = Account.new(:maximum_check_runs_per_day => 0)
        expect(account).not_to be_over_maximum_check_runs_today
      end
    end
  end

  describe "#as_json" do
    it "includes status" do
      expect(account.as_json["status"]).to eq("success")
    end

    context "when user is given" do
      let(:user) { create(:user, :account_admin, :current_account => account) }

      it "includes user's role" do
        expect(account.as_json(:for => user)["role"]).to eq("admin")
      end
    end
  end
end
