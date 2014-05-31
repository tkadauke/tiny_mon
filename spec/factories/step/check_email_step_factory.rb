FactoryGirl.define do
  factory :check_email_step do
    server "smtp.example.com"
    login "foobar"
    password "baz"
  end
end
