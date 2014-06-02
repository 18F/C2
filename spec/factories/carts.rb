FactoryGirl.define do
  factory :cart do
    name 'Test Cart needing approval'
    status 'pending'

    factory :cart_with_approval_group do
      after :create do |cart|
        approval_group = FactoryGirl.create(:approval_group_with_approvers)
        requester = FactoryGirl.create(:user, email_address: 'test-requester@communicart-stub.com')
        UserRole.create!(user_id: requester.id, approval_group_id: approval_group.id, role: 'requester')

        cart.approval_group = approval_group
        cart.save
      end
    end

  end
end
