FactoryGirl.define do
  factory :user do
    full_name 'John Doe'
    sequence(:email) { |n| "john.doe.#{n}@example.com" }
    password '12345'
    password_confirmation '12345'

    after(:create) do |user|
      user.current_account.users << user if user.current_account
    end

    trait :account_admin do
      after(:create) do |user|
        user.set_role_for_account(user.current_account, 'admin')
      end
    end

    trait :admin do
      after(:create) do |user|
        user.role = 'admin'
        user.save
      end
    end
  end
end
