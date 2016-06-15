FactoryGirl.define do
  factory :role do
    name "i-am-a-role"

    trait :observer do
      name ROLE_OBSERVER
    end
  end
end
