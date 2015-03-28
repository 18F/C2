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

    trait :with_proposal do
      proposal
    end

    trait :with_cart do
      association :proposal, :with_cart
    end

    trait :with_requester do
      association :proposal, :with_requester
    end

    trait :with_approvers do
      association :proposal, :with_approvers
    end
  end
end
