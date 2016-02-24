describe Dispatcher do
  describe ".deliver_new_proposal_emails" do
    it "sends emails to the requester and first approver and observers" do
      proposal = create(:proposal, :with_approver, :with_observer)

      Dispatcher.deliver_new_proposal_emails(proposal)

      expect(email_recipients).to eq([
        proposal.approvers.first.email_address,
        proposal.observers.first.email_address,
        proposal.requester.email_address
      ].sort)
    end
  end

  describe ".deliver_attachment_emails" do
    it "emails everyone currently involved in the proposal" do
      proposal = create(:proposal, :with_approver, :with_observer)
      attachment = create(:attachment, proposal: proposal)

      Dispatcher.deliver_attachment_emails(proposal, attachment)

      expect(email_recipients).to match_array(proposal.subscribers.map(&:email_address))
    end

    it "does not email pending approvers" do
      proposal = create(:proposal, :with_serial_approvers, :with_observer)
      attachment = create(:attachment, proposal: proposal)

      Dispatcher.deliver_attachment_emails(proposal, attachment)

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

      Dispatcher.deliver_attachment_emails(proposal, attachment)

      expect(email_recipients).not_to include(delegate_one.email_address)
      expect(email_recipients).not_to include(delegate_two.email_address)
    end
  end

  describe ".deliver_cancellation_emails" do
    it "sends a notification to the active step users" do
      mock_deliverer = double
      proposal = create(:proposal, :with_approval_and_purchase)
      proposal.approval_steps.first.complete!
      allow(CancellationMailer).to receive(:cancellation_notification).and_return(mock_deliverer)
      allow(mock_deliverer).to receive(:deliver_later).exactly(2).times

      Dispatcher.deliver_cancellation_emails(proposal)

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

      Dispatcher.deliver_cancellation_emails(proposal, reason)
    end

    it "sends an email to each actionable approver" do
      mock_deliverer = double
      serial_proposal = create(:proposal, :with_serial_approvers)
      allow(CancellationMailer).to receive(:cancellation_notification).and_return(mock_deliverer)
      expect(serial_proposal.approvers.count).to eq 2
      expect(mock_deliverer).to receive(:deliver_later).once

      Dispatcher.deliver_cancellation_emails(serial_proposal)
    end

    it "sends a confirmation email to the requester" do
      mock_deliverer = double
      proposal = create(:proposal, :with_approval_and_purchase)
      allow(CancellationMailer).to receive(:cancellation_confirmation).and_return(mock_deliverer)
      expect(mock_deliverer).to receive(:deliver_later).once

      Dispatcher.deliver_cancellation_emails(proposal)
    end
  end

  describe ".on_approval_approved" do
    context "ncr proposal" do
      it "notifies the user for the next pending step" do
        work_order = create(:ncr_work_order, :with_approvers)
        steps = work_order.individual_steps
        step_1 = steps.first
        step_2 = steps.second
        step_1.update(status: "approved", approved_at: Time.current)
        step_2.update(status: "actionable")

        Dispatcher.on_approval_approved(step_1)

        expect(email_recipients).to match_array([
          step_2.user.email_address
        ])
      end
    end

    context "non-ncr proposal" do
      it "notifies the requester and the user for the next pending step" do
        procurement = create(:gsa18f_procurement, :with_steps)
        steps = procurement.individual_steps
        step_1 = steps.first
        step_2 = steps.second
        step_1.update(status: "approved", approved_at: Time.current)
        step_2.update(status: "actionable")

        Dispatcher.on_approval_approved(step_1)

        expect(email_recipients).to match_array([
          step_2.user.email_address,
          procurement.proposal.requester.email_address
        ])
      end
    end
  end

  describe ".on_proposal_update" do
    context "non ncr proposal" do
      it "does not send any emails" do
        proposal = create(:test_client_request).proposal

        Dispatcher.on_proposal_update(proposal)

        expect(email_recipients).to eq []
      end
    end

    context "ncr proposal" do
      it "notifies approvers who have already approved" do
        work_order =  create(:ncr_work_order, :with_approvers)
        proposal = work_order.proposal
        steps = work_order.individual_steps
        step_1 = steps.first
        step_1.approve!
        deliveries.clear

        Dispatcher.on_proposal_update(proposal)

        email = deliveries[0]
        expect(email.to).to eq([step_1.user.email_address])
        expect(email.html_part.body.to_s).to include("already approved")
        expect(email.html_part.body.to_s).to include("updated")
      end

      it "current approver if they have been notified before" do
        work_order =  create(:ncr_work_order, :with_approvers)
        proposal = work_order.proposal
        steps = work_order.individual_steps
        step_1 = steps.first
        deliveries.clear
        create(:api_token, step: step_1)

        Dispatcher.on_proposal_update(proposal)

        email = deliveries[0]
        expect(email.to).to eq([step_1.user.email_address])
        expect(email.html_part.body.to_s).not_to include("already approved")
        expect(email.html_part.body.to_s).to include("updated")
      end

      it "does not notify observer if they are the one making the update" do
        work_order =  create(:ncr_work_order, :with_approvers)
        proposal = work_order.proposal
        email = "requester@example.com"
        user = create(:user, client_slug: "ncr", email_address: email)
        proposal.add_observer(user)

        Dispatcher.on_proposal_update(proposal, proposal.observers.first)

        expect(email_recipients).to_not include(email)
      end

      it "does not notify approver if they are the one making the update" do
        work_order =  create(:ncr_work_order, :with_approvers)
        proposal = work_order.proposal
        step_1 = work_order.individual_steps.first
        email = step_1.user.email_address

        Dispatcher.on_proposal_update(proposal, step_1.user)

        expect(email_recipients).to_not include(email)
      end

      it "notifies requester if they are not the one making the update" do
        work_order =  create(:ncr_work_order, :with_approvers)
        proposal = work_order.proposal
        step_1 = work_order.individual_steps.first

        Dispatcher.on_proposal_update(proposal, step_1.user)

        expect(email_recipients).to include(proposal.requester.email_address)
      end
    end
  end
end
