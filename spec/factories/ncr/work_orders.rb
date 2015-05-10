FactoryGirl.define do
  factory :ncr_work_order, class: Ncr::WorkOrder, parent: :proposal do
    amount 1000
    expense_type "BA61"
    vendor "Some Vend"
    not_to_exceed false
    building_number Ncr::BUILDING_NUMBERS[0]
    emergency false
    rwa_number "R1234567"
    office Ncr::OFFICES[0]
    project_title "NCR Name"
    flow 'linear'
    subclass 'Ncr::WorkOrder'
  end
end
