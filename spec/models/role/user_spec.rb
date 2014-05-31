require 'spec_helper'

describe Role::User do
  class TestAdminAccount
    include Role::Account::Admin
  end

  class TestUserAccount
    include Role::Account::User
  end

  class TestUser
    include Role::User
    def id
      42
    end
  end

  let(:user) { TestUser.new }

  describe "#can_see_profile?" do
    it "is true for own" do
      expect(user.can_see_profile?(user)).to be_true
    end

    it "is true for users in the same account" do
      other = TestUser.new
      expect(user).to receive(:shares_accounts_with?).with(other).and_return(true)
      expect(user.can_see_profile?(other)).to be_true
    end

    it "is false for others" do
      other = TestUser.new
      expect(user).to receive(:shares_accounts_with?).with(other).and_return(false)
      expect(user.can_see_profile?(other)).to be_false
    end
  end

  describe "#can_edit_profile?" do
    it "is true for own" do
      expect(user.can_edit_profile?(user)).to be_true
    end

    it "is false for others" do
      expect(user.can_edit_profile?(TestUser.new)).to be_false
    end
  end

  describe "#can_switch_to_account?" do
    it "is true if user is member" do
      expect(user).to receive(:user_account_for).and_return(TestUserAccount.new)
      expect(user.can_switch_to_account?(double(:id => 17))).to be_true
    end

    it "is false otherwise" do
      expect(user).to receive(:user_account_for).and_return(nil)
      expect(user.can_switch_to_account?(double(:id => 17))).to be_false
    end
  end

  describe "#can_remove_user_from_account?" do
    context "given user is account admin" do
      it "is true for others" do
        expect(user).to receive(:user_account_for).and_return(TestAdminAccount.new)
        expect(user.can_remove_user_from_account?(TestUser.new, double(:id => 17))).to be_true
      end
    end

    context "given user regular member" do
      it "is false" do
        expect(user).to receive(:user_account_for).and_return(TestUserAccount.new)
        expect(user.can_remove_user_from_account?(TestUser.new, double(:id => 17))).to be_false
      end
    end

    it "is false for self" do
      expect(user.can_remove_user_from_account?(user, double)).to be_false
    end
  end

  describe "#can_assign_role_for_user_and_account?" do
    context "given user is account admin" do
      it "is true for others" do
        expect(user).to receive(:user_account_for).and_return(TestAdminAccount.new)
        expect(user.can_assign_role_for_user_and_account?(TestUser.new, double(:id => 17))).to be_true
      end
    end

    context "given user is regular member" do
      it "is false" do
        expect(user).to receive(:user_account_for).and_return(TestUserAccount.new)
        expect(user.can_assign_role_for_user_and_account?(TestUser.new, double(:id => 17))).to be_false
      end
    end

    it "is false for self" do
      expect(user.can_assign_role_for_user_and_account?(user, double)).to be_false
    end
  end

  describe "#can_edit_health_check_template?" do
    it "is true for own" do
      expect(user.can_edit_health_check_template?(double(:user => user))).to be_true
    end

    it "is true for template from own account" do
      expect(user).to receive(:user_account_for).and_return(double(:can_edit_health_check_template? => true))
      expect(user.can_edit_health_check_template?(double(:user => double, :account => double))).to be_true
    end

    it "is false for others" do
      expect(user).to receive(:user_account_for)
      expect(user.can_edit_health_check_template?(double(:user => double, :account => double))).to be_false
    end
  end

  it "can edit settings" do
    expect(user.can_edit_settings?).to be_true
  end

  it "can see account details" do
    expect(user.can_see_account_details?).to be_true
  end

  it "can delete own health check templates" do
    expect(user.can_delete_health_check_template?(double(:user => user))).to be_true
  end

  it "cannot do anything else" do
    expect(user.can_do_whatever_he_wants?).to be_false
  end

  it "does not catch other methods" do
    expect { user.foobar }.to raise_error(NoMethodError)
  end
end
