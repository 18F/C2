describe Dispatcher do
  let(:proposal) { create(:proposal) }

  describe '.deliver_new_proposal_emails' do
    it "uses the NcrDispatcher for NCR approvals" do
      proposal.flow = 'linear'
      expect(proposal).to receive(:client_data).and_return(double(client_slug: "ncr"))
      expect_any_instance_of(NcrDispatcher).to receive(:deliver_new_proposal_emails).with(proposal)
      Dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  let(:proposal) { create(:proposal, :with_two_approvers) }
  let(:dispatcher) { Dispatcher.new }

  describe '#deliver_new_proposal_emails' do
    it "sends emails to the requester and all approvers" do
      dispatcher.deliver_new_proposal_emails(proposal)
      expect(email_recipients).to eq([
        proposal.approvers.first.email_address,
        proposal.requester.email_address
      ].sort)
    end

    it 'sends a proposal notification email to observers' do
      proposal.add_observer('observer1@example.com')
      expect(CommunicartMailer).to receive_message_chain(:proposal_observer_email, :deliver_later)
      dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe '#deliver_attachment_emails' do
    it "emails everyone currently involved in the proposal" do
      proposal.add_observer("wiley-cat@example.com")
      dispatcher.deliver_attachment_emails(proposal)
      expect(email_recipients).to match_array(proposal.subscribers.map(&:email_address) - [proposal.approvers.last.email_address])
    end

    it "does not email pending approvers" do
      dispatcher.deliver_attachment_emails(proposal)
      expect(email_recipients).to_not include(proposal.approvers.last.email_address)
    end

    it "does not email delegates" do
      wo = create(:ncr_work_order, :with_approvers)
      tier_one_approver = wo.proposal.approvers.second
      delegate_one = create(:user, client_slug: 'ncr')
      delegate_two = create(:user, client_slug: 'ncr')
      tier_one_approver.add_delegate(delegate_one)
      tier_one_approver.add_delegate(delegate_two)
      wo.proposal.individual_steps.first.approve!
      dispatcher.deliver_attachment_emails(wo.proposal)
      expect(email_recipients).to_not include(delegate_one.email_address)
    end
  end

  describe "#deliver_cancellation_emails" do
    let (:mock_deliverer) { double('deliverer') }

    it "sends an email to each approver who is aware of the proposal" do
      allow(CommunicartMailer).to receive(:cancellation_email).and_return(mock_deliverer)
      expect(proposal.approvers.count).to eq 2
      expect(proposal.individual_steps.where.not(status: "pending").count).to eq 1
      expect(mock_deliverer).to receive(:deliver_later).once

      dispatcher.deliver_cancellation_emails(proposal)
    end

    it "sends the reason to the cancellation email" do
      proposal = create(:proposal, :with_approver)
      approver = proposal.approvers.first
      reason = "reason for cancellation"
      allow(CommunicartMailer).to receive(:cancellation_email).
        with(approver.email_address, proposal, reason).
        and_return(mock_deliverer)

      expect(mock_deliverer).to receive(:deliver_later).once

      dispatcher.deliver_cancellation_emails(proposal, reason)
    end

    it "sends an email to each actionable approver" do
      allow(CommunicartMailer).to receive(:cancellation_email).and_return(mock_deliverer)
      expect(proposal.approvers.count).to eq 2
      expect(mock_deliverer).to receive(:deliver_later).once

      dispatcher.deliver_cancellation_emails(proposal)
    end

    it "sends a confirmation email to the requester" do
      allow(CommunicartMailer).to receive(:cancellation_confirmation).and_return(mock_deliverer)
      expect(mock_deliverer).to receive(:deliver_later).once

      dispatcher.deliver_cancellation_emails(proposal)
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester and the next approver" do
      proposal = create(:proposal, :with_two_approvers)
      approval = proposal.individual_steps.first
      approval.approve!   # calls on_approval_approved

      expect(email_recipients).to eq([
        proposal.approvers.second.email_address,
        proposal.requester.email_address
      ].sort)
    end
  end
end
