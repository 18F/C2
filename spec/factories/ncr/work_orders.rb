FactoryGirl.define do
  factory :ncr_work_order, class: Ncr::WorkOrder do
    amount 1000
    expense_type "BA61"
    vendor "Some Vend"
    not_to_exceed false
    building_number Ncr::BUILDING_NUMBERS[0]
    emergency false
    project_title "NCR Name"
    association :approving_official, factory: :user, client_slug: "ncr"
    association :proposal, client_slug: "ncr"

    factory :ba60_ncr_work_order do
      expense_type "BA60"
    end

    factory :ba61_ncr_work_order do
      expense_type "BA61"
    end

    factory :ba80_ncr_work_order do
      expense_type "BA80"
      rwa_number "R1234567"
    end

    trait :with_approvers do
      association :proposal, :with_serial_approvers, client_slug: "ncr"
    end

    trait :is_emergency do
      emergency true
      association :proposal, :with_observers
    end

    trait :with_observers do
      association :proposal, :with_observers, client_slug: "ncr"
    end
  end
end
