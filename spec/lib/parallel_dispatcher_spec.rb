require 'spec_helper'

describe ParallelDispatcher do
  after :each do
    ActionMailer::Base.deliveries.clear
  end

  describe '#deliver_new_cart_emails' do
    it "sends emails to all approvers" do
      dispatcher = ParallelDispatcher.new
      cart = FactoryGirl.create(:cart_with_approvals)

      dispatcher.deliver_new_cart_emails(cart)

      deliveries = ActionMailer::Base.deliveries
      expect(deliveries.count).to eq (2)

      emails = deliveries.map {|email| email.to[0] }.sort
      expect(emails).to eq([
        'approver1@some-dot-gov.gov',
        'approver2@some-dot-gov.gov'
      ])
    end
  end

  context 'old tests' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group, name: 'Cart with some approvals') }
    let(:dispatcher) { ParallelDispatcher.new }
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
      allow(ApiToken).to receive_message_chain(:where, :where, :last).and_return(api_token)
      cart.approvals << approval1
      cart.approvals << approval2
      cart.approvals << approval3
      cart.approvals << approval4
    end

    context 'approvers' do
      it 'creates a new token for each approver' do
        expect(ApiToken).to receive(:create!).exactly(2).times
        dispatcher.deliver_new_cart_emails(cart)
      end

      it 'sends a cart notification email to approvers' do
        mock_mailer = double
        expect(CommunicartMailer).to receive(:cart_notification_email).exactly(2).times.and_return(mock_mailer)
        expect(mock_mailer).to receive(:deliver).exactly(2).times
        dispatcher.deliver_new_cart_emails(cart)
      end
    end

    context 'observers' do
      it 'sends a cart notification email to observers' do
        mock_mailer = double
        expect(CommunicartMailer).to receive(:cart_observer_email).exactly(1).times.and_return(mock_mailer)
        expect(mock_mailer).to receive(:deliver).exactly(1).times
        dispatcher.deliver_new_cart_emails(cart)
      end
    end
  end
end
