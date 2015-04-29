FactoryGirl.define do
  factory :gsa18f_procurement, class: Gsa18f::Procurement do
    cost_per_unit 1000
    quantity 3
    additional_info "none"
    sequence(:product_name_and_description) {|n| "Proposal #{n}" }
    office Gsa18f::Procurement::OFFICES[0]
    urgency Gsa18f::Procurement::URGENCY[0]
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