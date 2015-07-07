FactoryGirl.define do
  factory :approval, class: Approvals::Individual do
    proposal
    user
    status 'pending'
  end
end
