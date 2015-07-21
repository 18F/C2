describe LinearDispatcher do
  let(:proposal) { FactoryGirl.create(:proposal, flow: 'linear') }
  let(:dispatcher) { LinearDispatcher.new }
  let(:requester) { FactoryGirl.create(:user, email_address: 'requester@some-dot-gov-domain.gov') }
  let(:approver) { FactoryGirl.create(:user, email_address: 'approver@some-dot-gov-domain.gov') }

  describe '#next_pending_approval' do
    context "no approvals" do
      it "returns nil" do
        expect(dispatcher.next_pending_approval(proposal)).to eq(nil)
      end
    end

    it "returns nil if all are non-pending" do
      proposal.approvals.create!(status: 'approved')
      expect(dispatcher.next_pending_approval(proposal)).to eq(nil)
    end

    it "sorts by position if there are more than one actionable approvals" do
      proposal.approvals.create!(position: 6, status: 'actionable')
      last_approval = proposal.approvals.create!(position: 5, status: 'actionable')

      expect(dispatcher.next_pending_approval(proposal)).to eq(last_approval)
    end

    it "returns nil if the proposal is rejected" do
      next_app = proposal.approvals.create!(position: 5, status: 'actionable')
      expect(dispatcher.next_pending_approval(proposal)).to eq(next_app)
      next_app.update_attribute(:status, 'rejected')  # skip state machine
      expect(dispatcher.next_pending_approval(proposal)).to eq(nil)
    end

    it "skips approved approvals" do
      first_approval = proposal.approvals.create!(position: 6, status: 'actionable')
      proposal.approvals.create!(position: 5, status: 'approved')

      expect(dispatcher.next_pending_approval(proposal)).to eq(first_approval)
    end

    it "skips non-approvers" do
      proposal.observations.create!
      approval = proposal.approvals.create!(status: 'actionable')

      expect(dispatcher.next_pending_approval(proposal)).to eq(approval)
    end
  end

  describe '#deliver_new_proposal_emails' do
    before do
      proposal.update_attributes!(requester_id: requester.id)
    end

    it "sends emails to the first approver" do
      approver
      approval = proposal.approvals.create!(user_id: approver.id, status: 'actionable')
      expect(dispatcher).to receive(:email_approver).with(approval)

      dispatcher.deliver_new_proposal_emails(proposal)
    end

    it "sends a proposal notification email to observers" do
      proposal.observations.create!
      expect(dispatcher).to receive(:email_observers).with(proposal)

      dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester and the next approver" do
      proposal = FactoryGirl.create(:proposal, :with_approvers, flow: 'linear')
      approval = proposal.approvals.first
      approval.approve!   # calls on_approval_approved
      expect(email_recipients).to eq([
        'approver2@some-dot-gov.gov',
        proposal.requester.email_address
      ])
    end
  end
end
