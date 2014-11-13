require 'spec_helper'

describe ParallelDispatcher do
  let(:cart) { FactoryGirl.create(:cart_with_approvals) }
  let(:dispatcher) { ParallelDispatcher.new }
  let(:deliveries) { ActionMailer::Base.deliveries }
  let(:delivery_emails) { deliveries.map {|email| email.to[0] }.sort }

  after do
    ActionMailer::Base.deliveries.clear
  end

  describe '#deliver_new_cart_emails' do
    it "sends emails to all approvers" do
      dispatcher.deliver_new_cart_emails(cart)

      expect(deliveries.count).to eq (2)
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
      observer_approval = FactoryGirl.create(:approval_with_user, role: 'observer')
      cart.approvals << observer_approval

      expect(CommunicartMailer).to receive_message_chain(:cart_observer_email, :deliver)
      dispatcher.deliver_new_cart_emails(cart)
    end
  end
end
