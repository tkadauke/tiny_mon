FactoryGirl.define do
  factory :health_check_import do
    trait :for_site do
      csv_data %{"foo"}
    end

    trait :for_account do
      csv_data %{"foo_site","foo","foo"}
    end

    factory :site_health_check_import, :traits => [:for_site]
    factory :account_health_check_import, :traits => [:for_account]
  end
end
