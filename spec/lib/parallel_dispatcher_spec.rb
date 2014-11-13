require 'spec_helper'

describe ParallelDispatcher do
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
end
