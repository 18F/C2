FactoryGirl.define do
  factory :proposal do
    flow 'parallel'
    status 'pending'
    association :requester, factory: :user

    trait :with_approver do
      after :create do |proposal|
        proposal.approver = create(:user)
      end
    end

    trait :with_serial_approvers do
      flow 'linear'
      after :create do |proposal|
        ind = 2.times.map{ Steps::Individual.new(user: create(:user)) }
        proposal.root_step = Steps::Serial.new(child_approvals: ind)
      end
    end

    trait :with_parallel_approvers do
      flow 'parallel'
      after :create do |proposal|
        ind = 2.times.map{ Steps::Individual.new(user: create(:user)) }
        proposal.root_step = Steps::Parallel.new(child_approvals: ind)
      end
    end

    trait :with_observer do
      after :create do |proposal|
        observer = create(:user)
        proposal.add_observer(observer.email_address)
      end
    end

    trait :with_observers do
      after :create do |proposal|
        2.times do
          observer = create(:user)
          proposal.add_observer(observer.email_address)
        end
      end
    end

    transient do
      delegate nil
    end

    after(:create) do |proposal, evaluator|
      if evaluator.delegate
        user = create(:user)
        proposal.approver = user
        user.add_delegate(evaluator.delegate)
      end
    end
  end
end
