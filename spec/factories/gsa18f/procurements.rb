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

    trait :with_steps do
      after(:create) { |procurement| procurement.initialize_steps }
    end

    trait :with_beta_requester do
      after(:create) do |procurement|
        procurement.initialize_steps
        requester = procurement.requester
        requester.roles << Role.find_by!(name: ROLE_BETA_USER)
        requester.roles << Role.find_by!(name: ROLE_BETA_ACTIVE)
      end
    end

    trait :with_beta_steps do
      after(:create) do |procurement|
        procurement.initialize_steps
        proposal = procurement.proposal
        ind = 3.times.map { Steps::Approval.new(user: create(:user, client_slug: "gsa18f")) }
        proposal.add_initial_steps(ind)
        requester = procurement.requester
        requester.roles << Role.find_by!(name: ROLE_BETA_USER)
        requester.roles << Role.find_by!(name: ROLE_BETA_ACTIVE)
      end
    end

  end
end
