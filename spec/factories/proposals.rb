FactoryGirl.define do
  factory :proposal do
    flow 'parallel'
    status 'pending'
    association :requester, factory: :user

    trait :with_approver do
      after :create do |proposal|
        proposal.add_approver('approver1@some-dot-gov.gov')
        proposal.kickstart_approvals()
      end
    end

    trait :with_serial_approvers do
      after :create do |proposal|
        proposal.root_approval = Approvals::Serial.new
        proposal.add_approver('approver1@some-dot-gov.gov')
        proposal.add_approver('approver2@some-dot-gov.gov')
        proposal.root_approval.make_actionable!
      end
    end

    trait :with_parallel_approvers do
      after :create do |proposal|
        proposal.root_approval = Approvals::Parallel.new
        proposal.add_approver('approver1@some-dot-gov.gov')
        proposal.add_approver('approver2@some-dot-gov.gov')
        proposal.kickstart_approvals()
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
