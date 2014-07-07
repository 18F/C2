require 'spec_helper'

describe Cart do
  describe '#update_approval_status' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group) }
    let(:cart_id) { 1357910 }

    context "All approvals are in 'approved' status" do
      it 'updates a status based on the cart_id passed in from the params' do
        cart.stub(:all_approvals_received?).and_return(true)

        cart.update_approval_status
        expect(cart.status).to eq('approved')
      end
    end

    context "Not all approvals are in 'approved'status" do
      it 'does not update the cart status' do
        cart.stub(:all_approvals_received?).and_return(false)

        cart.update_approval_status
        expect(cart.status).to eq('pending')
      end
    end
  end

  describe '#create_and_send_approvals' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group) }
    let(:api_token) { FactoryGirl.create(:api_token) }

    before do
      cart.stub(:api_token).and_return(api_token)
    end

    it 'creates a new token for each approver' do
      ApiToken.should_receive(:create!).exactly(2).times
      cart.create_and_send_approvals
    end

    it 'sends a cart notification email' do
      mock_mailer = double
      CommunicartMailer.should_receive(:cart_notification_email).exactly(2).times.and_return(mock_mailer)
      mock_mailer.should_receive(:deliver).exactly(2).times
      cart.create_and_send_approvals
    end
  end

end
