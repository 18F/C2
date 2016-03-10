describe NcrDispatcher do
  describe "#deliver_new_proposal_emails" do
    context "emergency work order" do
      it "sends the emergency proposal created confirmation" do
        ncr_dispatcher = NcrDispatcher.new
        work_order = create(:ncr_work_order, :is_emergency)
        proposal = work_order.proposal
        mailer_double = double(deliver_later: true)
        allow(ProposalMailer).to receive(:emergency_proposal_created_confirmation).
          with(proposal).
          and_return(mailer_double)

        ncr_dispatcher.deliver_new_proposal_emails(proposal)

        expect(ProposalMailer).to have_received(:emergency_proposal_created_confirmation).with(proposal)
      end
    end

    context "not an emergency work order" do
      it "sends the proposal created confirmation" do
        ncr_dispatcher = NcrDispatcher.new
        work_order = create(:ncr_work_order)
        proposal = work_order.proposal
        mailer_double = double(deliver_later: true)
        allow(ProposalMailer).to receive(:proposal_created_confirmation).
          with(proposal).
          and_return(mailer_double)

        ncr_dispatcher.deliver_new_proposal_emails(proposal)

        expect(ProposalMailer).to have_received(:proposal_created_confirmation).with(proposal)
      end
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester for the last approval" do
      step_1.update_attribute(:status, 'accepted')  # skip workflow
      deliveries.clear

      ncr_dispatcher.on_approval_approved(step_2)
      expect(email_recipients).to include(work_order.requester.email_address)
    end

    it "doesn't send to the requester for the not-last approval" do
      ncr_dispatcher.on_approval_approved(step_1)
      expect(email_recipients).to_not include('requester@example.com')
    end
  end

  describe '#requires_approval_notice?' do
    it 'returns true when the approval is last in the approver list' do
      expect(ncr_dispatcher.requires_approval_notice? step_2).to eq true
    end

    it 'return false when the approval is not last in the approver list' do
      expect(ncr_dispatcher.requires_approval_notice? step_1).to eq false
    end
  end

  describe "#step_complete" do
    it "notifies the user for the next pending step" do
      work_order = create(:ncr_work_order, :with_approvers)
      steps = work_order.individual_steps
      step_1 = steps.first
      step_2 = steps.second
      step_1.update(status: "approved", approved_at: Time.current)
      step_2.update(status: "actionable")

      NcrDispatcher.new(work_order.proposal).step_complete(step_1)

      expect(email_recipients).to match_array([
        step_2.user.email_address
      ])
    end
  end

  describe "#on_proposal_update" do
    context "proposal needs to be re-reviewed" do
      it "notifies pending step users" do
        work_order = create(:ncr_work_order, :with_approvers)
        first_step = work_order.individual_steps.first
        comment = create(:comment, proposal: work_order.proposal, user: work_order.requester)
        allow(StepMailer).to receive(:proposal_notification).
          with(first_step).
          and_return(double(deliver_later: true))

        NcrDispatcher.
          new(work_order.proposal).
          on_proposal_update(needs_review: true, comment: comment)

        expect(StepMailer).to have_received(:proposal_notification).with(first_step)
      end

      it "notifies requester and observers" do
        work_order = create(:ncr_work_order, :with_approvers)
        create(:observation, proposal_id: work_order.proposal.id)
        comment = create(:comment, proposal: work_order.proposal, user: work_order.approvers.first)
        allow(ProposalMailer).to receive(:proposal_updated_needs_re_review).
          and_return(double(deliver_later: true)).
          exactly(2).times

        NcrDispatcher.
          new(work_order.proposal).
          on_proposal_update(needs_review: true, comment: comment)

        expect(ProposalMailer).to have_received(:proposal_updated_needs_re_review).
          exactly(2).times
      end
    end

    context "proposal does not need re-review" do
      it "notifies step users" do
        work_order = create(:ncr_work_order, :with_approvers)
        comment = create(:comment, proposal: work_order.proposal, user: work_order.requester)
        first_step = work_order.individual_steps.first
        first_step.approve!
        allow(ProposalMailer).to receive(:proposal_updated_no_action_required).
          and_return(double(deliver_later: true))
        allow(ProposalMailer).to receive(:proposal_updated_no_action_required).
          with(first_step.user, work_order.proposal, comment).
          and_return(double(deliver_later: true)).
          exactly(1).times

        NcrDispatcher.
          new(work_order.proposal).
          on_proposal_update(needs_review: false, comment: comment)

        expect(ProposalMailer).to have_received(:proposal_updated_no_action_required).
          with(first_step.user, work_order.proposal, comment)
      end

      it "notifies requester" do
        work_order = create(:ncr_work_order, :with_approvers)
        comment = create(:comment, proposal: work_order.proposal, user: work_order.approvers.first)
        allow(ProposalMailer).to receive(:proposal_updated_no_action_required).
          and_return(double(deliver_later: true))
        allow(ProposalMailer).to receive(:proposal_updated_no_action_required).
          with(work_order.requester, work_order.proposal, comment).
          and_return(double(deliver_later: true)).
          exactly(1).times

        NcrDispatcher.
          new(work_order.proposal).
          on_proposal_update(needs_review: false, comment: comment)

        expect(ProposalMailer).to have_received(:proposal_updated_no_action_required).
          with(work_order.requester, work_order.proposal, comment)
      end

      it "notifies observers" do
        work_order = create(:ncr_work_order, :with_approvers)
        comment = create(:comment, proposal: work_order.proposal, user: work_order.requester)
        observation = create(:observation, proposal_id: work_order.proposal.id)
        allow(ProposalMailer).to receive(:proposal_updated_no_action_required).
          and_return(double(deliver_later: true))
        allow(ProposalMailer).to receive(:proposal_updated_no_action_required).
          with(observation.user, work_order.proposal, comment).
          and_return(double(deliver_later: true)).
          exactly(1).times

        NcrDispatcher.
          new(work_order.proposal).
          on_proposal_update(needs_review: false, comment: comment)

        expect(ProposalMailer).to have_received(:proposal_updated_no_action_required).
          with(observation.user, work_order.proposal, comment)
      end
    end

    context "proposal has pending step during update" do
      it "notifies the pending step user of update" do
        work_order = create(:ncr_work_order, :with_approvers)
        comment = create(:comment, proposal: work_order.proposal, user: work_order.requester)
        first_step = work_order.individual_steps.first
        create(:api_token, step: first_step)
        allow(ProposalMailer).to receive(:proposal_updated_while_step_pending).
          with(first_step, comment).
          and_return(double(deliver_later: true))

        NcrDispatcher.
          new(work_order.proposal).
          on_proposal_update(needs_review: false, comment: comment)

        expect(ProposalMailer).
          to have_received(:proposal_updated_while_step_pending).
          with(first_step, comment)
      end
    end

    it "does not notify observer if they are the one making the update" do
      work_order =  create(:ncr_work_order, :with_approvers)
      user = create(:user, client_slug: "ncr")
      proposal = work_order.proposal
      proposal.add_observer(user)
      comment = create(:comment, proposal: work_order.proposal, user: proposal.observers.first)

      NcrDispatcher.
        new(proposal).
        on_proposal_update(needs_review: false, comment: comment)

      expect(email_recipients).to_not include(user.email_address)
    end

    it "does not notify approver if they are the one making the update" do
      work_order =  create(:ncr_work_order, :with_approvers)
      step_1 = work_order.individual_steps.first
      comment = create(:comment, proposal: work_order.proposal, user: step_1.user)
      proposal = work_order.proposal
      email = step_1.user.email_address

      NcrDispatcher.
        new(proposal).
        on_proposal_update(needs_review: false, comment: comment)

      expect(email_recipients).to_not include(email)
    end

    it "notifies requester if they are not the one making the update" do
      work_order =  create(:ncr_work_order, :with_approvers)
      step_1 = work_order.individual_steps.first
      comment = create(:comment, proposal: work_order.proposal, user: step_1.user)
      proposal = work_order.proposal

      NcrDispatcher.
        new(proposal).
        on_proposal_update(needs_review: false, comment: comment)

      expect(email_recipients).to include(proposal.requester.email_address)
    end
  end
end
