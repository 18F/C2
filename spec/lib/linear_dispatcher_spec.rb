describe LinearDispatcher do
  let(:cart) { FactoryGirl.create(:cart) }
  let(:proposal) { cart.proposal }
  let(:dispatcher) { LinearDispatcher.new }
  let(:requester) { FactoryGirl.create(:user, email_address: 'requester@some-dot-gov-domain.gov') }
  let(:approver) { FactoryGirl.create(:user, email_address: 'approver@some-dot-gov-domain.gov') }

  describe '#next_pending_approval' do
    context "no approvals" do
      it "returns nil" do
        expect(dispatcher.next_pending_approval(cart)).to eq(nil)
      end
    end

    it "returns nil if all are non-pending" do
      proposal.approvals.create!(status: 'approved')
      expect(dispatcher.next_pending_approval(cart)).to eq(nil)
    end

    it "returns the first pending approval by position" do
      proposal.approvals.create!(position: 6)
      last_approval = proposal.approvals.create!(position: 5)

      expect(dispatcher.next_pending_approval(cart)).to eq(last_approval)
    end

    it "returns nil if the cart is rejected" do
      next_app = proposal.approvals.create!(position: 5)
      expect(dispatcher.next_pending_approval(cart)).to eq(next_app)
      next_app.update_attribute(:status, 'rejected')  # skip state machine
      expect(dispatcher.next_pending_approval(cart)).to eq(nil)
    end

    it "skips approved approvals" do
      first_approval = proposal.approvals.create!(position: 6)
      proposal.approvals.create!(position: 5, status: 'approved')

      expect(dispatcher.next_pending_approval(cart)).to eq(first_approval)
    end

    it "skips non-approvers" do
      proposal.observations.create!
      approval = proposal.approvals.create!

      expect(dispatcher.next_pending_approval(cart)).to eq(approval)
    end
  end

  describe '#deliver_new_proposal_emails' do
    before do
      proposal.update_attributes!(requester_id: requester.id)
    end

    it "sends emails to the first approver" do
      approver
      approval = proposal.approvals.create!(user_id: approver.id)
      expect(dispatcher).to receive(:email_approver).with(approval)

      dispatcher.deliver_new_proposal_emails(proposal)
    end

    it "sends a cart notification email to observers" do
      proposal.observations.create!
      expect(dispatcher).to receive(:email_observers).with(cart)

      dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester and the next approver" do
      cart = FactoryGirl.create(:cart_with_approvals)
      approval = cart.approvals.first
      approval.update_attribute(:status, 'approved')  # avoiding state machine
      dispatcher.on_approval_approved(approval)
      expect(email_recipients).to eq([
        'approver2@some-dot-gov.gov',
        'requester@some-dot-gov.gov'
      ])
    end
  end
end
