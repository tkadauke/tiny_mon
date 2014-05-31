require 'spec_helper'

describe Role::Account::Observer do
  class TestObserverAccount
    include Role::Account::Observer
  end

  let(:user) { TestObserverAccount.new }

  it "is not able to do anything interesting" do
    expect(user.can_do_whatever_he_wants?).to be_false
  end

  it "does not catch other methods" do
    expect { user.foobar }.to raise_error(NoMethodError)
  end
end
