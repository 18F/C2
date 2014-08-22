require 'spec_helper'

describe ApprovalGroup do
  let(:approval_group) { FactoryGirl.create(:approval_group, name: 'test-approval-group') }
  let(:cart) { FactoryGirl.create(:cart, name: 'test-cart') }
  let(:user1) { FactoryGirl.create(:user, email_address: 'user1@some-dot-gov.gov') }
  let(:user2) { FactoryGirl.create(:user, email_address: 'user2@some-dot-gov.gov') }

  context 'valid attributes' do
    it 'should be valid with valid attributes' do
      expect(approval_group).to be_valid
    end
  end

  context 'relationships' do
    it 'has a cart' do
      approval_group.update_attributes(cart_id: cart.id)
      expect(approval_group.cart).to eq cart
    end

    it 'has user roles' do
      user_role = UserRole.create!(user_id: user1.id, approval_group_id: approval_group.id, role: 'approver')
      expect(approval_group.user_roles).to eq [user_role]
    end

    it 'has users' do
      user_role = UserRole.create!(user_id: user1.id, approval_group_id: approval_group.id, role: 'approver')
      user_role = UserRole.create!(user_id: user2.id, approval_group_id: approval_group.id, role: 'requester')
      expect(approval_group.users).to eq [user1, user2]
    end

  end

  context 'invalid attributes' do
    it 'should not be valid with a missing name' do
      approval_group.update_attributes(name: nil)
      expect(approval_group).not_to be_valid
    end

    it 'should not be valid with a duplicate name' do
      approval_group
      another_approval_group = FactoryGirl.build(:approval_group, name: 'test-approval-group')
      expect(another_approval_group).to_not be_valid
    end
  end

end