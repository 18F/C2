require 'spec_helper'

describe ParallelDispatcher do
  let(:dispatcher) { ParallelDispatcher.new }

  after :each do
    ActionMailer::Base.deliveries.clear
  end

  describe '#deliver_new_cart_emails' do
    it "sends emails to all approvers" do
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
    let(:cart) { FactoryGirl.create(:cart_with_approval_group) }
    let(:approval1) { FactoryGirl.create(:approval_with_user, role: 'approver') }
    let(:approval2) { FactoryGirl.create(:approval_with_user, role: 'approver') }
    let(:approval3) { FactoryGirl.create(:approval_with_user, role: 'requester') }
    let(:approval4) { FactoryGirl.create(:approval_with_user, role: 'observer') }

    before do
      cart.approvals << approval1
      cart.approvals << approval2
      cart.approvals << approval3
      cart.approvals << approval4
    end

    context 'approvers' do
      it 'creates a new token for each approver' do
        api_token = FactoryGirl.create(:api_token)
        allow(ApiToken).to receive_message_chain(:where, :where, :last).and_return(api_token)
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
