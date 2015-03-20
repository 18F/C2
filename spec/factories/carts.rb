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


    factory :cart_with_approval_group do
      after :create do |cart|
        approval_group = FactoryGirl.create(:approval_group_with_approver_and_requester_approvals)

        cart.approval_group = approval_group
        cart.save!
      end
    end

    factory :cart_with_requester do
      after :create do |cart|
        requester = FactoryGirl.create(:user, email_address: 'requester1@some-dot-gov.gov', first_name: 'Panthro', last_name: 'Requester')
        cart.proposal.approvals << FactoryGirl.create(:approval, role: 'requester', user_id: requester.id)
      end
    end

    factory :cart_with_approvals do
      after :create do |cart|
        cart.add_approver('approver1@some-dot-gov.gov')
        cart.add_approver('approver2@some-dot-gov.gov')
        cart.add_requester('requester@some-dot-gov.gov')
      end

      factory :cart_with_all_approvals_approved do
        after :create do |cart|
          cart.approvals.each {|a| a.approve!}
        end
      end
    end

    factory :cart_with_observers do
      after :create do |cart|
        #TODO: change approval_group to use a factory that adds observers
        approval_group = FactoryGirl.create(:approval_group_with_approvers_observers_and_requester)

        cart.approval_group = approval_group
        cart.save!
      end
    end

  end
end
