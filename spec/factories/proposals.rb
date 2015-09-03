FactoryGirl.define do
  factory :proposal do
    flow 'parallel'
    status 'pending'
    association :requester, factory: :user

    trait :with_approver do
      after :create do |proposal|
        proposal.approvers = [FactoryGirl.create(:user)]
      end
    end


    trait :with_serial_approvers do
      flow 'linear'
      after :create do |proposal|
        proposal.approvers = 2.times.map{ FactoryGirl.create(:user) }
      end
    end

    trait :with_parallel_approvers do
      flow 'parallel'
      after :create do |proposal|
        proposal.approvers = 2.times.map{ FactoryGirl.create(:user) }
      end
    end

    trait :with_observer do
      after :create do |proposal|
        observer = FactoryGirl.create(:user)
        proposal.add_observer(observer.email_address)
      end
    end

    trait :with_observers do
      after :create do |proposal|
        observer_role = FactoryGirl.create(:role, :observer)
        2.times do
          observer = FactoryGirl.create(:user)
          proposal.add_observer(observer.email_address)
        end
      end
    end
  end
end
