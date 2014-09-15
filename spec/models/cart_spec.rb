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

  describe '#deliver_approval_emails' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group, name: 'Cart with some approvals') }
    let(:user1) { FactoryGirl.create(:user, email_address: 'user1@some-dot-gov.gov') }
    let(:user2) { FactoryGirl.create(:user, email_address: 'user2@some-dot-gov.gov') }
    let(:user3) { FactoryGirl.create(:user, email_address: 'user3@some-dot-gov.gov') }
    let(:user4) { FactoryGirl.create(:user, email_address: 'user4@some-dot-gov.gov') }
    let(:approval1) { FactoryGirl.create(:approval, user_id: user1.id, cart_id: cart.id, role: 'approver') }
    let(:approval2) { FactoryGirl.create(:approval, user_id: user2.id, cart_id: cart.id, role: 'approver') }
    let(:approval3) { FactoryGirl.create(:approval, user_id: user3.id, cart_id: cart.id, role: 'requester') }
    let(:approval4) { FactoryGirl.create(:approval, user_id: user4.id, cart_id: cart.id, role: 'observer') }
    let(:api_token) { FactoryGirl.create(:api_token) }

    before do
      ApiToken.stub_chain(:where, :where, :last).and_return(api_token)
      cart.approvals << approval1
      cart.approvals << approval2
      cart.approvals << approval3
      cart.approvals << approval4
    end

    context 'approvers' do
      it 'creates a new token for each approver' do
        ApiToken.should_receive(:create!).exactly(2).times
        cart.deliver_approval_emails
      end

      it 'sends a cart notification email to approvers' do
        mock_mailer = double
        CommunicartMailer.should_receive(:cart_notification_email).exactly(2).times.and_return(mock_mailer)
        mock_mailer.should_receive(:deliver).exactly(2).times
        cart.deliver_approval_emails
      end
    end

    context 'observers' do
      it 'sends a cart notification email to observers' do
        mock_mailer = double
        CommunicartMailer.should_receive(:cart_observer_email).exactly(1).times.and_return(mock_mailer)
        mock_mailer.should_receive(:deliver).exactly(1).times
        cart.deliver_approval_emails
      end
    end
  end

end
