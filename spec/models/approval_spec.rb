require 'spec_helper'

describe Approval do

  let(:cart) { FactoryGirl.create(:cart) }
  let(:approval) { FactoryGirl.create(:approval) }
  let(:params) { { approval_action: 'approved', cart_id: 5678 } }

  describe '#update_statuses' do
    before do
      Cart.stub(:find_by_id).and_return(cart)
      cart.approvals << approval
    end

    it 'updates its own approval status' do
      approval.update_statuses(params)
      expect(approval.status).to eq 'approved'
    end

    it 'update tells its cart to update its own status' do
      Cart.should_receive(:update_status_for_cart).with(5678)
      approval.update_statuses(params)
      # expect(approval.cart.status).to eq 'approved'
    end
  end
end
