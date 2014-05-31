FactoryGirl.define do
  factory :site do
    name "example.com"
    url "http://www.example.com"
    association :account
  end
end
