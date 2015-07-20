FactoryGirl.define do
  factory :proposal do
    flow 'parallel'
    status 'pending'
    association :requester, factory: :user

    trait :with_approver do
      after :create do |proposal|
        proposal.create_or_update_approvals([
          Approvals::Individual.new(user: User.for_email('approver1@some-dot-gov.gov'))
        ])
      end
    end

    trait :with_serial_approvers do
      after :create do |proposal|
        root = Approvals::Serial.new
        proposal.create_or_update_approvals([
          root,
          Approvals::Individual.new(user: User.for_email('approver1@some-dot-gov.gov'), parent: root),
          Approvals::Individual.new(user: User.for_email('approver2@some-dot-gov.gov'), parent: root),
        ])
      end
    end

    trait :with_parallel_approvers do
      after :create do |proposal|
        root = Approvals::Parallel.new
        proposal.create_or_update_approvals([
          root,
          Approvals::Individual.new(user: User.for_email('approver1@some-dot-gov.gov'), parent: root),
          Approvals::Individual.new(user: User.for_email('approver2@some-dot-gov.gov'), parent: root),
        ])
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
