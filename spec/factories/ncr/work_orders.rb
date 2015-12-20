FactoryGirl.define do
  factory :ncr_work_order, class: Ncr::WorkOrder do
    amount 1000
    expense_type "BA61"
    vendor "Some Vend"
    not_to_exceed false
    building_number Ncr::BUILDING_NUMBERS[0]
    emergency false
    project_title "NCR Name"
    sequence(:approving_official_email) {|n| "approver#{User.count}@example.com" }
    association :proposal, flow: 'linear'

    factory :ba80_ncr_work_order do
      expense_type "BA80"
      rwa_number "R1234567"
    end

    trait :with_approvers do
      association :proposal, :with_serial_approvers, flow: 'linear', client_slug: "ncr"
      after :create do |wo|
        wo.approving_official_email = wo.approving_official.email_address
      end
    end

    trait :is_emergency do
      emergency true
      association :proposal, :with_observers, flow: 'linear'
    end

    trait :with_observers do
      association :proposal, :with_observers, flow: 'linear'
    end
  end
end
