FactoryGirl.define do
  factory :proposal do
    flow 'parallel'
    status 'pending'

    trait :with_cart do
      cart
    end
  end
end
