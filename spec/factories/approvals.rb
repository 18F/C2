FactoryGirl.define do
  factory :approval do
    proposal
    user
    status 'pending'
  end
end
