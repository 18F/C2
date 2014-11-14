require 'spec_helper'

describe Dispatcher do
  let(:cart) { FactoryGirl.create(:cart) }

  describe '.deliver_new_cart_emails' do
    it "uses the ParallelDispatcher for parallel approvals" do
      cart.flow = 'parallel'
      expect_any_instance_of(ParallelDispatcher).to receive(:deliver_new_cart_emails).with(cart)
      Dispatcher.deliver_new_cart_emails(cart)
    end

    it "uses the LinearDispatcher for linear approvals" do
      cart.flow = 'linear'
      expect_any_instance_of(LinearDispatcher).to receive(:deliver_new_cart_emails).with(cart)
      Dispatcher.deliver_new_cart_emails(cart)
    end
  end

  describe '#email_approver' do
    let(:dispatcher) { Dispatcher.new }

    it 'creates a new token for the approver' do
      approval = FactoryGirl.create(:approval_with_user, cart_id: cart.id)
      expect(CommunicartMailer).to receive_message_chain(:cart_notification_email, :deliver)

      api_token = FactoryGirl.create(:api_token)
      allow(ApiToken).to receive_message_chain(:where, :where, :last).and_return(api_token)
      expect(ApiToken).to receive(:create!).exactly(1).times

      dispatcher.email_approver(approval)
    end
  end
end
