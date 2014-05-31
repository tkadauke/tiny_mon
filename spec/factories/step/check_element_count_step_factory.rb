FactoryGirl.define do
  factory :check_element_count_step do
    scope "div"
    name "table"
    mincount 1
    maxcount 2
  end
end
