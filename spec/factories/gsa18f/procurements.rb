FactoryGirl.define do
  factory :gsa18f_procurement, class: Gsa18f::Procurement do
    cost_per_unit 1000
    quantity 3
    additional_info "none"
    sequence(:product_name_and_description) {|n| "Proposal #{n}" }
    office Gsa18f::Procurement::OFFICES[0]
    urgency Gsa18f::Procurement::URGENCY[10]
    association :proposal, flow: 'linear', client_slug: 'gsa18f'

    #todo: Probably shouldn't be required, remove once #98376564 is fixed
    after :create do |p|
      p.proposal.update(public_id: p.proposal.public_identifier)
    end
  end
end
