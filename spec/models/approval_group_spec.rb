require 'spec_helper'

describe ApprovalGroup do
  let(:approval_group) { FactoryGirl.create(:approval_group, name: 'test-approval-group') }
  let(:cart) { FactoryGirl.create(:cart, name: 'test-cart') }
  let(:user1) { FactoryGirl.create(:user, email_address: 'user1@some-dot-gov.gov') }
  let(:user2) { FactoryGirl.create(:user, email_address: 'user2@some-dot-gov.gov') }
  let(:requester) { FactoryGirl.create(:user, id: 13579) }

  context 'valid attributes' do
    it 'should be valid with valid attributes' do
      expect(approval_group).to be_valid
    end

    it "fails validation with a flow that isn't in the list" do
      approval_group.flow = 'badflow'
      expect(approval_group).to_not be_valid
      expect(approval_group.errors[:flow]).to_not be_empty
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
      UserRole.create!(user_id: user1.id, approval_group_id: approval_group.id, role: 'approver')
      UserRole.create!(user_id: user2.id, approval_group_id: approval_group.id, role: 'requester')
      expect(approval_group.users).to eq [user1, user2]
    end

    describe '#approvers' do
      it "returns associated users" do
        UserRole.create!(user_id: user1.id, approval_group_id: approval_group.id, role: 'approver', position: 1)
        UserRole.create!(user_id: user2.id, approval_group_id: approval_group.id, role: 'approver', position: 0)
        expect(approval_group.approvers).to eq([user1, user2])
      end
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

  describe '#requester_id' do
    it "returns the requester's id" do
      UserRole.create!(user_id: requester.id, approval_group_id: approval_group.id, role: 'requester')
      expect(approval_group.requester_id).to eq 13579
    end

    it 'returns nil when there is no requester' do
      expect(approval_group.requester_id).to eq nil
    end
  end
end
