FactoryGirl.define do
  factory :cart do
    name 'Test Cart needing approval'

    # hack to allow the :flow and :status to be passed as arguments to the factory
    # https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#associations
    transient do
      flow 'parallel'
      status 'pending'
    end

    after(:build) do |cart, evaluator|
      cart.proposal = create(:proposal,
        flow: evaluator.flow,
        status: evaluator.status
      )
    end


    trait :with_requester do
      after :create do |cart|
        cart.add_requester('requester@some-dot-gov.gov')
      end
    end

    factory :cart_with_approvals do
      with_requester

      after :create do |cart|
        cart.add_approver('approver1@some-dot-gov.gov')
        cart.add_approver('approver2@some-dot-gov.gov')
        cart.proposal.initialize_approvals()
      end

      factory :cart_with_all_approvals_approved do
        after :create do |cart|
          cart.approvals.each {|a| a.approve!}
        end
      end
    end
  end
end
