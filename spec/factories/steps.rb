FactoryGirl.define do
  factory :step, class: Steps::Approval do
    proposal
    user
    status 'pending'

    factory :serial_steps, class: Steps::Serial do
    end
  end
end
