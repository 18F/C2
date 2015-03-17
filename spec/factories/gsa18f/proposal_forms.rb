FactoryGirl.define do
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