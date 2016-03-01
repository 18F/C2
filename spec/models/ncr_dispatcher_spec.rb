describe NcrDispatcher do
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
    context "proposal complete" do
      context "needs to be re-reviewed" do
        it "notifies step users they need to re-review" do
          work_order = create(:ncr_work_order, :with_approvers)
          first_step = work_order.individual_steps.first
          first_step.approve!
          allow(ProposalMailer).to receive(:proposal_updated_step_complete_needs_re_review).
            and_return(double(deliver_later: true))

          NcrDispatcher.new(work_order.proposal).on_proposal_update(modifier: nil, needs_review: true)

          expect(ProposalMailer).to have_received(:proposal_updated_step_complete_needs_re_review)
        end
      end

      context "does not need re-review" do
        it "notifiers step users of update" do
          work_order = create(:ncr_work_order, :with_approvers)
          first_step = work_order.individual_steps.first
          first_step.approve!
          allow(ProposalMailer).to receive(:proposal_updated_step_complete).
            and_return(double(deliver_later: true))

          NcrDispatcher.new(work_order.proposal).on_proposal_update(modifier: nil, needs_review: false)

          expect(ProposalMailer).to have_received(:proposal_updated_step_complete)
        end
      end
    end

    context "proposal is not complete" do
      it "notifies approvers who have already approved" do
        work_order =  create(:ncr_work_order, :with_approvers)
        proposal = work_order.proposal
        steps = work_order.individual_steps
        step_1 = steps.first
        step_1.approve!
        deliveries.clear

        NcrDispatcher.new(proposal).on_proposal_update(modifier: nil, needs_review: false)

        email = deliveries[0]
        expect(email.to).to eq([step_1.user.email_address])
        expect(email.html_part.body.to_s).to include(
          I18n.t("mailer.proposal_mailer.proposal_updated_step_complete.header")
        )
      end

      it "current approver if they have been notified before" do
        work_order =  create(:ncr_work_order, :with_approvers)
        proposal = work_order.proposal
        steps = work_order.individual_steps
        step_1 = steps.first
        deliveries.clear
        create(:api_token, step: step_1)

        NcrDispatcher.new(proposal).on_proposal_update(modifier: nil, needs_review: false)

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

        NcrDispatcher.new(proposal).on_proposal_update(modifier: proposal.observers.first, needs_review: false)

        expect(email_recipients).to_not include(email)
      end

      it "does not notify approver if they are the one making the update" do
        work_order =  create(:ncr_work_order, :with_approvers)
        proposal = work_order.proposal
        step_1 = work_order.individual_steps.first
        email = step_1.user.email_address

        NcrDispatcher.new(proposal).on_proposal_update(modifier: step_1.user, needs_review: false)

        expect(email_recipients).to_not include(email)
      end

      it "notifies requester if they are not the one making the update" do
        work_order =  create(:ncr_work_order, :with_approvers)
        proposal = work_order.proposal
        step_1 = work_order.individual_steps.first

        NcrDispatcher.new(proposal).on_proposal_update(modifier: step_1.user, needs_review: false)

        expect(email_recipients).to include(proposal.requester.email_address)
      end
    end
  end
end
