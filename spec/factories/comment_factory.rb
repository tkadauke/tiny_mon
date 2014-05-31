FactoryGirl.define do
  factory :comment do
    title "hello"
    text "world"
    association :check_run
    association :user
  end
end
