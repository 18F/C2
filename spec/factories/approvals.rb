FactoryGirl.define do
  factory :approval, class: Approvals::Individual do
    proposal
    user
    status 'pending'

    factory :parallel_approval, class: Approvals::Parallel do
    end

    factory :individual_approval, class: Approvals::Individual do
    end
  end
end
