FactoryGirl.define do
  factory :cart do
    flow 'parallel'
    name 'Test Cart needing approval'
    status 'pending'

    factory :cart_with_approval_group do
      after :create do |cart|
        approval_group = FactoryGirl.create(:approval_group_with_approver_and_requester_approvals)

        cart.approval_group = approval_group
        cart.save!
      end
    end

    factory :cart_with_approvals do
      after :create do |cart|
        approver1 = FactoryGirl.create(:user, email_address: 'approver1@some-dot-gov.gov', first_name: 'Liono', last_name: 'Approver1')
        approver2 = FactoryGirl.create(:user, email_address: 'approver2@some-dot-gov.gov', first_name: 'Liono', last_name: 'Approver2')
        requester = FactoryGirl.create(:user, email_address: 'requester@some-dot-gov.gov', first_name: 'Liono', last_name: 'Requester')

        cart.approvals << FactoryGirl.create(:approval, role: 'approver', user_id: approver1.id)
        cart.approvals << FactoryGirl.create(:approval, role: 'approver', user_id: approver2.id)
        cart.approvals << FactoryGirl.create(:approval, role: 'requester', user_id: requester.id)
        cart.save!
      end

      factory :cart_with_all_approvals_approved do
        after :create do |cart|
          cart.approvals.each {|a| a.update_attribute :status, 'approved'}
          cart.update_attribute :status, 'approved'
        end
      end

      factory :cart_with_approvals_and_items do
        after :create do |cart|
          cart.cart_items << FactoryGirl.create(:cart_item, cart_id: cart.id)
          cart.cart_items << FactoryGirl.create(:cart_item, cart_id: cart.id,vendor: "Spud Vendor")
          cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait,name: 'socio',value: "W")
          cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait,name: 'socio',value: "S")
          cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait,name: 'socio',value: "O")
          cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait,name: 'features',value: "discount")
          cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait,name: 'features',value: "feature2")
          cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait,name: 'green',value: 'blah')

          cart.save!
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
