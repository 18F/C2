require 'rails_helper'

describe 'Adding and retrieving comments from a cart item' do

  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

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


  it 'updates the comments on a cart item as expected' do
    ENV['NOTIFICATION_FROM_EMAIL'] = 'sender@some-dot_gov.gov'

    expect(Cart.count).to eq(1)
    expect(User.count).to eq(4)
    cart = Cart.first
    expect(cart.status).to eq 'pending'
    expect(cart.approvals.where(status: 'approved').count).to eq 0
    expect(cart.comments.count).to eq 0
    expect(ActionMailer::Base.deliveries.count).to eq 0

    cart_item = cart.cart_items.first
    expect(cart_item.comments.count).to eq 0

    cart_item.comments << Comment.new(user_id: 34567,comment_text: "This needs to change from a quantity of 250 to 500")
    cart_item.save
    expect(cart_item.comments.count).to eq 1
    expect(ActionMailer::Base.deliveries.count).to eq 4

    cart_item.comments << Comment.new(user_id: 34567,comment_text: "Thank you for the update. I will change it no to 250 quantity")
    cart_item.save
    expect(cart_item.comments.count).to eq 2
    expect(ActionMailer::Base.deliveries.count).to eq 8
  end

  after do
    ActionMailer::Base.deliveries.clear
  end
end
