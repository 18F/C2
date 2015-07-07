FactoryGirl.define do
  factory :approval do
    proposal
    user
    type 'Approvals::Individual'
    status 'pending'
  end
end
