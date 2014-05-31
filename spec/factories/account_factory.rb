FactoryGirl.define do
  factory :account do
    sequence(:name) { |n| "account#{n}" }
  end
end
