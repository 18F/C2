FactoryGirl.define do
  factory :proposal do
    flow 'parallel'
    status 'pending'
    association :requester, factory: :user

    trait :with_approver do
      after :create do |proposal|
        proposal.set_approver_to(FactoryGirl.create(:user))
      end
    end


    trait :with_serial_approvers do
      flow 'linear'
      after :create do |proposal|
        ind = 2.times.map{ Approvals::Individual.new(user: FactoryGirl.create(:user)) }
        root = Approvals::Serial.new(child_approvals: ind)
        proposal.set_approvals_to([root] + ind)
      end
    end

    trait :with_parallel_approvers do
      flow 'parallel'
      after :create do |proposal|
        ind = 2.times.map{ Approvals::Individual.new(user: FactoryGirl.create(:user)) }
        root = Approvals::Parallel.new(child_approvals: ind)
        proposal.set_approvals_to([root] + ind)
      end
    end

    trait :with_observers do
      after :create do |proposal|
        proposal.add_observer('observer1@some-dot-gov.gov')
        proposal.add_observer('observer2@some-dot-gov.gov')
      end
    end
  end
end
