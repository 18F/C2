FactoryGirl.define do
  factory :step, class: Steps::Approval do
    proposal
    user
    status 'pending'
  end
end
