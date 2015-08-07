describe LinearDispatcher do
  let(:dispatcher) { LinearDispatcher.new }

  describe '#next_pending_approval' do
    context "no approvals" do
      it "returns nil" do
        proposal = FactoryGirl.create(:proposal, flow: 'linear')
        expect(dispatcher.next_pending_approval(proposal)).to eq(nil)
      end
    end

    it "returns nil if all are non-pending" do
      proposal = FactoryGirl.create(:proposal, :with_approver, flow: 'linear')
      proposal.root_approval.approve!
      expect(dispatcher.next_pending_approval(proposal)).to eq(nil)
    end

    it "skips approved approvals" do
      proposal = FactoryGirl.create(:proposal, :with_serial_approvers)
      last_approval = proposal.individual_approvals.last
      proposal.individual_approvals.first.approve!

      expect(dispatcher.next_pending_approval(proposal)).to eq(last_approval)
    end

    it "skips non-approvers" do
      proposal = FactoryGirl.create(:proposal, :with_approver, :with_observers)
      approval = proposal.approvals.first

      expect(dispatcher.next_pending_approval(proposal)).to eq(approval)
    end
  end

  describe '#deliver_new_proposal_emails' do
    it "sends emails to the first approver" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      approval = proposal.approvals.first

      expect(dispatcher).to receive(:email_approver).with(approval)

      dispatcher.deliver_new_proposal_emails(proposal)
    end

    it "sends a proposal notification email to observers" do
      proposal = FactoryGirl.create(:proposal, :with_observers)

      expect(dispatcher).to receive(:email_observers).with(proposal)

      dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester and the next approver" do
      proposal = FactoryGirl.create(:proposal, :with_serial_approvers)
      approval = proposal.individual_approvals.first
      approval.approve!   # calls on_approval_approved
      expect(email_recipients).to eq([
        proposal.approvers.second.email_address,
        proposal.requester.email_address
      ].sort)
    end
  end
end
