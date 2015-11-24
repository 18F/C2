FactoryGirl.define do
  factory :step, class: Steps::Approval do
    proposal
    user
    status 'pending'

    factory :serial_steps, class: Steps::Serial do
    end

    factory :parallel_steps, class: Steps::Parallel do
    end

    factory :purchase_step, class: Steps::Purchase do
    end
  end
end
