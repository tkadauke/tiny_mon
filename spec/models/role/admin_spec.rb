require 'spec_helper'

describe Role::Admin do
  class TestAdmin
    include Role::Admin
    def id
      42
    end
  end

  let(:user) { TestAdmin.new }

  it "can do anything" do
    expect(user.can_do_whatever_he_wants?).to be_true
  end

  it "does not catch other methods" do
    expect { user.foobar }.to raise_error(NoMethodError)
  end
end
