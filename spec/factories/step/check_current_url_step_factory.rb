FactoryGirl.define do
  factory :check_current_url_step do
    url "http://www.google.com"
    negate false
  end
end
