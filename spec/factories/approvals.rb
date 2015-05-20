FactoryGirl.define do
  factory :approval do
    proposal_id 1
    user_id 1
    status 'pending'

    trait :with_proposal do
      proposal
    end

    trait :with_user do
      user
    end
  end
end
