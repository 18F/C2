require 'spec_helper'

describe 'Adding and retrieving comments from a cart item' do

  before do
    approval_group = ApprovalGroup.create(name: "A Testworthy Approval Group")

    cart = Cart.new(
                    name: 'My Wonderfully Awesome Communicart',
                    status: 'pending',
                    external_id: '10203040'
                    )
    user = User.create!(email_address: 'test-requester@some-dot-gov.gov')

    UserRole.create!(user_id: user.id, approval_group_id: approval_group.id, role: 'requester')
    cart.approval_group = approval_group

    cart.approvals << Approval.create!(user_id: user.id, role: 'requester')
    cart.cart_items << FactoryGirl.create(:cart_item)
    cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait)
    cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait,name: "feature",value: "bpa")
    cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait,name: "socio",value: "w")
    cart.cart_items[0].cart_item_traits << FactoryGirl.create(:cart_item_trait,name: "socio",value: "v")

    (1..3).each do |num|
      email = "approver#{num}@some-dot-gov.gov"

      user = FactoryGirl.create(:user, email_address: email)
      approval_group.user_roles << UserRole.create!(user_id: user.id, approval_group_id: approval_group.id, role: 'approver')
      cart.approvals << Approval.create!(user_id: user.id, role: 'approver')
    end

    cart.save

  end

end
