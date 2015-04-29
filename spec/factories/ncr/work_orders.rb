FactoryGirl.define do
  factory :ncr_work_order, class: Ncr::WorkOrder do
    amount 1000
    expense_type "BA61"
    vendor "Some Vend"
    not_to_exceed false
    building_number Ncr::BUILDING_NUMBERS[0]
    emergency false
    rwa_number "RWWAAA #"
    office Ncr::OFFICES[0]
    name "NCR Name"

    trait :with_proposal do
      association :proposal, flow: 'linear'
    end

    trait :with_cart do
      association :proposal, :with_cart, flow: 'linear'
    end

    trait :with_requester do
      association :proposal, :with_requester, flow: 'linear'
    end

    trait :with_approvers do
      association :proposal, :with_approvers, flow: 'linear'
    end

    trait :full do
      association :proposal, :with_cart, :with_requester, :with_approvers,
        flow: 'linear'
    end
  end
end
