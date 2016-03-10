describe NcrDispatcher do
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
