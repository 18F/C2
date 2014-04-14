FactoryGirl.define do
  factory :cart do
    name 'Test Cart needing approval'
    status 'pending'

    factory :cart_with_multiple_approvals do #TODO: Remove
      after :create do |cart|
        cart.approvals << Approval.create(email_address: "george.jetson@spacelysprockets.com", status: 'pending')
        cart.approvals << Approval.create(email_address: "judy.jetson@spacelysprockets.com", status: 'pending')
        cart.save
      end
    end

    factory :cart_with_an_approval_group do
      after :create do |cart|
        cart.approval_group = FactoryGirl.create(:multipleapprovers)
        cart.save
      end
    end

  end
end
