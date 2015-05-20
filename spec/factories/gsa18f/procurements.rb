FactoryGirl.define do
  factory :gsa18f_procurement, class: Gsa18f::Procurement do
    cost_per_unit 1000
    quantity 3
    additional_info "none"
    sequence(:product_name_and_description) {|n| "Proposal #{n}" }
    office Gsa18f::Procurement::OFFICES[0]
    urgency Gsa18f::Procurement::URGENCY[0]
    association :proposal, flow: 'linear'

    trait :with_approvers do
      association :proposal, :with_approvers
    end
  end
end
