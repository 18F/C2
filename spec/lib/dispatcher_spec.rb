require 'spec_helper'

describe Dispatcher do
  let(:cart) { FactoryGirl.create(:cart) }
  let(:dispatcher) { Dispatcher.new }

  describe '#email_approver' do
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
