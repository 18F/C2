require 'spec_helper'

describe ApprovalGroup do

  let(:approval_group) { FactoryGirl.create(:approval_group) }
  let(:requester) { FactoryGirl.create(:user, id: 13579) }

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
