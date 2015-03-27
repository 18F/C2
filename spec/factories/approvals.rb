FactoryGirl.define do
  factory :approval do
    proposal_id 1
    user_id 1
    status 'pending'

    factory :approval_with_user do
      user
    end

    trait :with_cart do
      association :proposal, :with_cart
    end
  end
end
