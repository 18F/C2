FactoryGirl.define do
  sequence(:public_id) { |n| "PUBLIC#{n}" }

  factory :proposal do
    public_id
    flow 'linear'
    status 'pending'
    association :requester, factory: :user

    transient do
      client_slug { nil }
      delegate nil
      observer nil
      approver_user nil
    end

    trait :with_approver do
      after :create do |proposal, evaluator|
        user = evaluator.approver_user || create(:user, client_slug: evaluator.client_slug)
        proposal.add_initial_steps([Steps::Approval.new(user: user)])
      end
    end

    trait :with_serial_approvers do
      flow 'linear'
      after :create do |proposal, evaluator|
        ind = 2.times.map{ Steps::Approval.new(user: create(:user, client_slug: evaluator.client_slug)) }
        proposal.add_initial_steps(ind)
      end
    end

    trait :with_parallel_approvers do
      flow 'parallel'
      after :create do |proposal, evaluator|
        ind = 2.times.map{ Steps::Approval.new(user: create(:user, client_slug: evaluator.client_slug)) }
        proposal.root_step = Steps::Parallel.new(child_approvals: ind)
      end
    end

    trait :with_approval_and_purchase do
      flow "linear"
      after :create do |proposal, evaluator|
        first_approver = create(:user, client_slug: evaluator.client_slug)
        second_approver = create(:user, client_slug: evaluator.client_slug)
        steps = [
          create(:approval, user: first_approver),
          create(:purchase_step, user: second_approver)
        ]
        proposal.add_initial_steps(steps)
      end
    end

    trait :with_observer do
      after :create do |proposal, evaluator|
        observer = create(:user, client_slug: evaluator.client_slug)
        proposal.add_observer(observer.email_address)
      end
    end

    trait :with_observers do
      after :create do |proposal, evaluator|
        2.times do
          observer = create(:user, client_slug: evaluator.client_slug)
          proposal.add_observer(observer.email_address)
        end
      end
    end

    after(:create) do |proposal, evaluator|
      if evaluator.observer
        proposal.add_observer(evaluator.observer.email_address)
      end

      if evaluator.delegate
        user = evaluator.approver_user || create(:user, client_slug: evaluator.client_slug)
        proposal.add_initial_steps([Steps::Approval.new(user: user)])
        user.add_delegate(evaluator.delegate)
      end

      if evaluator.client_slug
        proposal.requester.client_slug = evaluator.client_slug
        proposal.requester.save!
      end
    end
  end
end
