FactoryGirl.define do
  factory :gsa18f_procurement, class: Gsa18f::Procurement do
    cost_per_unit 1000
    purchase_type 0
    quantity 3
    additional_info "none"
    sequence(:product_name_and_description) {|n| "Proposal #{n}" }
    office Gsa18f::Procurement::OFFICES[0]
    urgency Gsa18f::Procurement::URGENCY[10]
    association :proposal, client_slug: "gsa18f"

    transient do
      requester nil
    end

    after(:create) do |procurement, evaluator|
      if evaluator.requester
        procurement.proposal.update(requester: evaluator.requester)
      end
    end

    trait :with_steps do
      after(:create) { |procurement| procurement.add_steps }
    end
  end
end
