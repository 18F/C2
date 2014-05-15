FactoryGirl.define do
  factory :cart do
    name 'Test Cart needing approval'
    status 'pending'

    factory :cart_with_approval_group do
      after :create do |cart|
        cart.requester = FactoryGirl.create(:requester)
        cart.approval_group = FactoryGirl.create(:approval_group_with_approvers)
        cart.save
      end
    end

  end
end
