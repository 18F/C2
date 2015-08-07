FactoryGirl.define do
  factory :ncr_work_order, class: Ncr::WorkOrder do
    amount 1000
    expense_type "BA61"
    vendor "Some Vend"
    not_to_exceed false
    building_number Ncr::BUILDING_NUMBERS[0]
    emergency false
    rwa_number "R1234567" # TODO remove, since it's not applicable for BA61
    org_code Ncr::Organization.all[0].to_s
    project_title "NCR Name"
    association :proposal, flow: 'linear'

    trait :with_approvers do
      association :proposal, :with_serial_approvers, flow: 'linear'
    end

    trait :is_emergency do
      emergency true
      association :proposal, :with_observers, flow: 'linear'
    end

    #todo: Probably shouldn't be required, remove once #98376564 is fixed
    after :create do |wo|
      wo.proposal.update(public_id: wo.proposal.public_identifier)
    end
  end
end
