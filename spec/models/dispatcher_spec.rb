describe Dispatcher do
  let(:proposal) { create(:proposal) }

  describe ".deliver_new_proposal_emails" do
    it "uses the LinearDispatcher for non-NCR approvals" do
      expect(proposal).to receive(:client_data).and_return(double(client_slug: "ncr"))
      expect_any_instance_of(LinearDispatcher).to receive(:deliver_new_proposal_emails).with(proposal)
      Dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  let(:proposal) { create(:proposal, :with_parallel_approvers) }
  let(:serial_proposal) { create(:proposal, :with_serial_approvers) }
  let(:dispatcher) { Dispatcher.new }

  describe '#deliver_new_proposal_emails' do
    it "sends emails to the requester and all approvers" do
      dispatcher.deliver_new_proposal_emails(proposal)
      expect(email_recipients).to eq([
        proposal.approvers.first.email_address,
        proposal.approvers.second.email_address,
        proposal.requester.email_address
      ].sort)
    end

    it 'sends a proposal notification email to observers' do
      observer = create(:user)
      proposal.add_observer(observer)
      expect(ObserverMailer).to receive_message_chain(:proposal_observer_email, :deliver_later)
      dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe "#deliver_attachment_emails" do
    it "emails everyone currently involved in the proposal" do
      observer = create(:user)
      proposal.add_observer(observer)
      attachment = create(:attachment, proposal: proposal)
      dispatcher.deliver_attachment_emails(proposal, attachment)
      expect(email_recipients).to match_array(proposal.subscribers.map(&:email_address))
    end

    it "does not email pending approvers" do
      attachment = create(:attachment, proposal: proposal)
      dispatcher.deliver_attachment_emails(serial_proposal, attachment)
      expect(email_recipients).to_not include(serial_proposal.approvers.last.email_address)
    end

    it "does not email delegates" do
      attachment = create(:attachment, proposal: proposal)
      wo = create(:ncr_work_order, :with_approvers)
      tier_one_approver = wo.proposal.approvers.second
      delegate_one = create(:user, client_slug: 'ncr')
      delegate_two = create(:user, client_slug: 'ncr')
      tier_one_approver.add_delegate(delegate_one)
      tier_one_approver.add_delegate(delegate_two)
      wo.proposal.individual_steps.first.approve!
      dispatcher.deliver_attachment_emails(wo.proposal, attachment)
      expect(email_recipients).to_not include(delegate_one.email_address)
    end
  end

  describe "#deliver_cancellation_emails" do
    let (:mock_deliverer) { double("deliverer") }

    it "sends a notification to the active step users" do
      proposal = create(:proposal, :with_approval_and_purchase)
      proposal.approval_steps.first.approve!
      allow(CancellationMailer).to receive(:cancellation_notification).and_return(mock_deliverer)
      allow(mock_deliverer).to receive(:deliver_later).exactly(2).times

      dispatcher.deliver_cancellation_emails(proposal)

      expect(mock_deliverer).to have_received(:deliver_later).exactly(2).times
    end

    it "sends the reason to the cancellation notification" do
      proposal = create(:proposal, :with_approver)
      approver = proposal.approvers.first
      reason = "reason for cancellation"
      allow(CancellationMailer).to receive(:cancellation_notification).
        with(approver.email_address, proposal, reason).
        and_return(mock_deliverer)

      expect(mock_deliverer).to receive(:deliver_later).once

      dispatcher.deliver_cancellation_emails(proposal, reason)
    end

    it "sends an email to each actionable approver" do
      allow(CancellationMailer).to receive(:cancellation_notification).and_return(mock_deliverer)
      expect(serial_proposal.approvers.count).to eq 2
      expect(mock_deliverer).to receive(:deliver_later).once

      dispatcher.deliver_cancellation_emails(serial_proposal)
    end

    it "sends a confirmation email to the requester" do
      allow(CancellationMailer).to receive(:cancellation_confirmation).and_return(mock_deliverer)
      expect(mock_deliverer).to receive(:deliver_later).once

      dispatcher.deliver_cancellation_emails(proposal)
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester and the next approver" do
      proposal = create(:proposal, :with_serial_approvers)
      dispatcher.on_approval_approved(proposal.individual_steps.first)
      expect(email_recipients).to eq([proposal.requester.email_address])
    end
  end
end
