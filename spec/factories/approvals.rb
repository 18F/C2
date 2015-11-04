FactoryGirl.define do
  factory :approval, class: Steps::Approval do
    proposal
    user
    status 'pending'
  end

  factory :parallel_approval, class: Steps::Parallel do
  end
end
