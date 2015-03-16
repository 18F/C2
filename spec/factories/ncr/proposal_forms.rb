FactoryGirl.define do
  factory :proposal_form, class: Ncr::ProposalForm do
    amount 1000
    sequence(:approver_email) {|n| "approver#{n}@example.com" }
    sequence(:description) {|n| "Proposal #{n}" }
    expense_type 'BA80'
    building_number 'Entire WH Complex'
    office Ncr::ProposalForm::OFFICES[0]
    association :requester, factory: :user
    sequence(:vendor) {|n| "Vendor #{n}" }
  end
  factory :gsa18f_proposal_form, class: Gsa18f::ProposalForm do
    cost_per_unit 1000
    quantity 3
    additional_info "none"
    sequence(:product_name_and_description) {|n| "Proposal #{n}" }
    office Gsa18f::ProposalForm::OFFICES[0]
    urgency Gsa18f::ProposalForm::URGENCY[0]
    association :requester, factory: :user
  end
end