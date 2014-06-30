FactoryGirl.define do
  factory :cart do
    name 'Test Cart needing approval'
    status 'pending'

    factory :cart_with_approval_group do
      after :create do |cart|
        approval_group = FactoryGirl.create(:approval_group_with_approver_and_requester_approvals)

        cart.approval_group = approval_group
        cart.save
      end
    end

  end
end
