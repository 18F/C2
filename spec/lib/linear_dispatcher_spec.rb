require 'spec_helper'

describe LinearDispatcher do
  let(:cart) { FactoryGirl.create(:cart) }
  let(:dispatcher) { LinearDispatcher.new }
  let(:deliveries) { ActionMailer::Base.deliveries }
  let(:delivery_emails) { deliveries.map {|email| email.to[0] }.sort }

  describe '#next_approval' do
    context "no approvals" do
      it "returns nil" do
        expect(dispatcher.next_approval(cart)).to eq(nil)
      end
    end

    it "returns nil if all are non-pending" do
      cart.approvals.create!(role: 'approver', status: 'approved')
      expect(dispatcher.next_approval(cart)).to eq(nil)
    end

    it "returns the first pending approval by position" do
      cart.approvals.create!(position: 6, role: 'approver')
      last_approval = cart.approvals.create!(position: 5, role: 'approver')

      expect(dispatcher.next_approval(cart)).to eq(last_approval)
    end

    it "skips approved approvals" do
      first_approval = cart.approvals.create!(position: 6, role: 'approver')
      cart.approvals.create!(position: 5, role: 'approver', status: 'approved')

      expect(dispatcher.next_approval(cart)).to eq(first_approval)
    end

    it "skips non-approvers" do
      cart.approvals.create!(role: 'observer')
      approval = cart.approvals.create!(role: 'approver')

      expect(dispatcher.next_approval(cart)).to eq(approval)
    end
  end

  describe '#deliver_new_cart_emails' do
    it "sends emails to the first approver" do
      approval = cart.approvals.create!(role: 'approver')
      expect(dispatcher).to receive(:email_approver).with(approval)

      dispatcher.deliver_new_cart_emails(cart)
    end

    it "sends a cart notification email to observers" do
      cart.approvals.create!(role: 'observer')
      expect(dispatcher).to receive(:email_observers).with(cart)

      dispatcher.deliver_new_cart_emails(cart)
    end
  end

  xdescribe '#on_approval_status_change' do
    it "sends to the requester and the next approver" do
      dispatcher.on_approval_status_change(cart.approvals.first)
      expect(delivery_emails).to eq([
        'approver2@some-dot-gov.gov',
        'requester@some-dot-gov.gov'
      ])
    end
  end

  describe '#ordered_approvals' do
    let(:cart) { FactoryGirl.create(:cart_with_approvals) }

    it "returns users in order of position" do
      cart.approvals.first.update_attribute(:position, 5)
      expect(dispatcher.ordered_approvals(cart)).to eq(cart.awaiting_approvals.reverse)
    end
  end
end
