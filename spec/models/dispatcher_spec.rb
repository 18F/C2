describe Dispatcher do
  describe "#deliver_new_proposal_emails" do
    it "sends emails to the requester and first approver and observers" do
      proposal = create(:proposal, :with_approver, :with_observer)

      Dispatcher.new(proposal).deliver_new_proposal_emails

      expect(email_recipients).to eq([
        proposal.approvers.first.email_address,
        proposal.observers.first.email_address,
        proposal.requester.email_address
      ].sort)
    end
  end

  describe "#deliver_attachment_emails" do
    it "emails everyone currently involved in the proposal" do
      proposal = create(:proposal, :with_approver, :with_observer)
      attachment = create(:attachment, proposal: proposal)

      Dispatcher.new(proposal).deliver_attachment_emails(attachment)

      expect(email_recipients).to match_array(proposal.subscribers.map(&:email_address))
    end

    it "does not email pending approvers" do
      proposal = create(:proposal, :with_serial_approvers, :with_observer)
      attachment = create(:attachment, proposal: proposal)

      Dispatcher.new(proposal).deliver_attachment_emails(attachment)

      expect(email_recipients).to_not include(proposal.approvers.last.email_address)
    end

    it "does not email delegates" do
      proposal = create(:proposal, :with_serial_approvers, :with_observer)
      attachment = create(:attachment, proposal: proposal)
      tier_one_approver = proposal.approvers.second
      delegate_one = create(:user, client_slug: "ncr")
      delegate_two = create(:user, client_slug: "ncr")
      tier_one_approver.add_delegate(delegate_one)
      tier_one_approver.add_delegate(delegate_two)
      wo.proposal.individual_steps.first.complete!

      Dispatcher.new(proposal).deliver_attachment_emails(attachment)

      expect(email_recipients).not_to include(delegate_one.email_address)
      expect(email_recipients).not_to include(delegate_two.email_address)
    end
  end

  describe "#deliver_cancellation_emails" do
    it "sends a notification to the active step users" do
      mock_deliverer = double
      proposal = create(:proposal, :with_approval_and_purchase)
      proposal.approval_steps.first.complete!
      allow(CancellationMailer).to receive(:cancellation_notification).and_return(mock_deliverer)
      allow(mock_deliverer).to receive(:deliver_later).exactly(2).times

      Dispatcher.new(proposal).deliver_cancellation_emails

      expect(mock_deliverer).to have_received(:deliver_later).exactly(2).times
    end

    it "sends the reason to the cancellation notification" do
      mock_deliverer = double
      proposal = create(:proposal, :with_approver)
      approver = proposal.approvers.first
      reason = "reason for cancellation"
      allow(CancellationMailer).to receive(:cancellation_notification).
        with(approver.email_address, proposal, reason).
        and_return(mock_deliverer)

      expect(mock_deliverer).to receive(:deliver_later).once

      Dispatcher.new(proposal).deliver_cancellation_emails(reason)
    end

    it "sends an email to each actionable approver" do
      mock_deliverer = double
      serial_proposal = create(:proposal, :with_serial_approvers)
      allow(CancellationMailer).to receive(:cancellation_notification).and_return(mock_deliverer)
      expect(serial_proposal.approvers.count).to eq 2
      expect(mock_deliverer).to receive(:deliver_later).once

      Dispatcher.new(serial_proposal).deliver_cancellation_emails
    end

    it "sends a confirmation email to the requester" do
      mock_deliverer = double
      proposal = create(:proposal, :with_approval_and_purchase)
      allow(CancellationMailer).to receive(:cancellation_confirmation).and_return(mock_deliverer)
      expect(mock_deliverer).to receive(:deliver_later).once

      Dispatcher.new(proposal).deliver_cancellation_emails
    end
  end

  describe "#on_approval_approved" do
    it "notifies the requester and the user for the next pending step" do
      procurement = create(:gsa18f_procurement, :with_steps)
      steps = procurement.individual_steps
      step_1 = steps.first
      step_2 = steps.second
      step_1.update(status: "approved", approved_at: Time.current)
      step_2.update(status: "actionable")

      Dispatcher.new(procurement.proposal).on_approval_approved(step_1)

      expect(email_recipients).to match_array([
        step_2.user.email_address,
        procurement.proposal.requester.email_address
      ])
    end
  end

  describe "#on_proposal_update" do
    it "does not send any emails" do
      proposal = create(:test_client_request).proposal

      Dispatcher.new(proposal).on_proposal_update

      expect(email_recipients).to eq []
    end
  end
end
