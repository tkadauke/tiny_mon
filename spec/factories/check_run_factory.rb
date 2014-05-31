FactoryGirl.define do
  factory :check_run do
    started_at { 2.seconds.ago }
    ended_at { Time.now }
    status "success"
    log { [[Time.now, "Some message"]] }
    association :health_check
  end
end
