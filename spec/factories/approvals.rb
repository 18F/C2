FactoryGirl.define do
  factory :approval do
    proposal_id 1
    user_id 1
    status 'pending'
    role 'approver'

    factory :approval_with_user do
      user
    end

    # after :build do |approval|
    #   approval.cart ||= FactoryGirl.create(:cart)
    # end

    trait :with_cart do
      association :proposal, :with_cart
    end
  end
end
