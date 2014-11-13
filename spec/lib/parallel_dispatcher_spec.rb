require 'spec_helper'

describe ParallelDispatcher do
  let(:cart) { FactoryGirl.create(:cart_with_approvals) }
  let(:dispatcher) { ParallelDispatcher.new }
  let(:deliveries) { ActionMailer::Base.deliveries }
  let(:delivery_emails) { deliveries.map {|email| email.to[0] }.sort }

  describe '#deliver_new_cart_emails' do
    it "sends emails to all approvers" do
      dispatcher.deliver_new_cart_emails(cart)
      expect(delivery_emails).to eq([
        'approver1@some-dot-gov.gov',
        'approver2@some-dot-gov.gov'
      ])
    end

    it 'creates a new token for each approver' do
      api_token = FactoryGirl.create(:api_token)
      allow(ApiToken).to receive_message_chain(:where, :where, :last).and_return(api_token)
      expect(ApiToken).to receive(:create!).exactly(2).times

      dispatcher.deliver_new_cart_emails(cart)
    end

    it 'sends a cart notification email to observers' do
      cart.approvals << FactoryGirl.create(:approval_with_user, role: 'observer')
      expect(CommunicartMailer).to receive_message_chain(:cart_observer_email, :deliver)
      dispatcher.deliver_new_cart_emails(cart)
    end
  end

  describe '#deliver_approval_email' do
    it "sends to the requester" do
      dispatcher.deliver_approval_email(cart.approvals.first)
      expect(delivery_emails).to eq(['requester@some-dot-gov.gov'])
    end
  end
end
