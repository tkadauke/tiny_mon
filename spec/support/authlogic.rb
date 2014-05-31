require "authlogic/test_case"
include Authlogic::TestCase

module Authlogic
  module TestHelper
    def login_with(user)
      UserSession.create(user)
    end

    def logout
      UserSession.find.destroy
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    activate_authlogic
  end
  config.include Authlogic::TestHelper, type: :controller
end
