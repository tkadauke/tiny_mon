require 'spec_helper'

describe Role::Account::Admin do
  class TestAdminAccount
    include Role::Account::Admin
  end

  let(:user) { TestAdminAccount.new }

  it "can do anything" do
    expect(user.can_do_whatever_he_wants?).to be_true
  end

  it "does not catch other methods" do
    expect { user.foobar }.to raise_error(NoMethodError)
  end
end
