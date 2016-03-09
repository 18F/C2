FactoryGirl.define do
  factory :step do
    proposal
    user
  end

  factory :approval_step, class: Steps::Approval do
    proposal
    user

    factory :serial_step, class: Steps::Serial do
    end

    factory :parallel_step, class: Steps::Parallel do
    end

    factory :purchase_step, class: Steps::Purchase do
    end
  end
end
