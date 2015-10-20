FactoryGirl.define do
  factory :approval, class: Steps::Individual do
    proposal
    user
    status 'pending'
  end
end
