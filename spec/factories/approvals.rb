FactoryGirl.define do
  factory :approval, class: Steps::Approval do
    proposal
    user
    status 'pending'
  end
end
