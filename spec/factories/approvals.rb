FactoryGirl.define do
  factory :approval, class: Approvals::Individual do
    proposal
    user
    status 'pending'
  end

  factory :parallel_approval, class: Approvals::Parallel do
  end
end
