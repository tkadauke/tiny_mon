FactoryGirl.define do
  factory :health_check do
    name "Home Page"
    interval 10
    enabled true
    association :site
  end
end
