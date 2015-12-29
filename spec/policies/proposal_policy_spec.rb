describe ProposalPolicy do
  permissions :can_complete? do
    it "allows pending delegates" do
      proposal = create(:proposal, :with_parallel_approvers)

      approval = proposal.individual_steps.first
      delegate = create(:user)
      approver = approval.user
      approver.add_delegate(delegate)

      expect(ProposalPolicy).to permit(delegate, proposal)
    end

    context "parallel proposal" do
      let(:proposal) {create(:proposal, :with_parallel_approvers)}
      let(:approval) {proposal.individual_steps.first}

      it "allows when there's a pending approval" do
        proposal.approvers.each{ |approver|
          expect(ProposalPolicy).to permit(approver, proposal)
        }
      end

      it "does not allow when the user's already approved" do
        approval.update_attribute(:status, 'approved')  # skip state machine
        expect(ProposalPolicy).not_to permit(approval.user, proposal)
      end

      it "does not allow with a non-existent approval" do
        user = create(:user)
        expect(ProposalPolicy).not_to permit(user, proposal)
      end
    end

    context "linear proposal" do
      it "allows when there's a pending approval" do
        proposal = create(:proposal)
        first_approval = create(:approval_step, proposal: proposal, status: "actionable")

        expect(ProposalPolicy).to permit(first_approval.user, proposal)
      end

      it "allows when there's a pending purchase" do
        proposal = create(:proposal)
        _first_approval = create(:approval_step, proposal: proposal, status: "approved")
        purchase_step = create(:purchase_step, proposal: proposal, status: "actionable")

        expect(ProposalPolicy).to permit(purchase_step.user, proposal)
      end

      it "does not allow when it's not the user's turn" do
        proposal = create(:proposal)
        _first_approval = create(:approval_step, proposal: proposal)
        second_approval = create(:approval_step, proposal: proposal)

        expect(ProposalPolicy).not_to permit(second_approval.user, proposal)
      end

      it "does not allow when the user's already approved" do
        proposal = create(:proposal)
        first_approval = create(:approval_step, proposal: proposal, status: "approved")
        second_approval = create(:approval_step, proposal: proposal, status: "actionable")

        expect(ProposalPolicy).not_to permit(first_approval.user, proposal)
        expect(ProposalPolicy).to permit(second_approval.user, proposal)
      end

      it "does not allow with a non-existent approval" do
        user = create(:user)
        expect(ProposalPolicy).not_to permit(user, proposal)
      end
    end
  end

  permissions :can_show? do
    let(:proposal) {create(:proposal, :with_parallel_approvers, :with_observers)}

    it "allows the requester to see it" do
      expect(ProposalPolicy).to permit(proposal.requester, proposal)
    end

    it "allows an approver to see it" do
      expect(ProposalPolicy).to permit(proposal.approvers[0], proposal)
      expect(ProposalPolicy).to permit(proposal.approvers[1], proposal)
    end

    it "does not allow a pending approver to see it" do
      first_approval = proposal.individual_steps.first
      first_approval.update_attribute(:status, 'pending')
      expect(ProposalPolicy).not_to permit(first_approval.user, proposal)
      expect(ProposalPolicy).to permit(proposal.approvers.last, proposal)
    end

    it "allows an observer to see it" do
      expect(ProposalPolicy).to permit(proposal.observers[0], proposal)
    end

    it "does not allow anyone else to see it" do
      expect(ProposalPolicy).not_to permit(create(:user), proposal)
    end
  end

  permissions :can_edit? do
    it "allows the requester to edit" do
      expect(ProposalPolicy).to permit(proposal.requester, proposal)
    end

    it "allows an admin to edit" do
      admin = create(:user)
      admin.add_role("admin")
      expect(ProposalPolicy).to permit(admin, proposal)
    end

    it "doesn't allow an approver to edit it" do
      expect(ProposalPolicy).not_to permit(proposal.approvers[0], proposal)
      expect(ProposalPolicy).not_to permit(proposal.approvers[1], proposal)
    end

    it "doesn't allow an observer to edit it" do
      expect(ProposalPolicy).not_to permit(proposal.observers[0], proposal)
    end

    it "does not allow anyone else to edit it" do
      expect(ProposalPolicy).not_to permit(create(:user), proposal)
    end

    it "does not allow an approved request to be edited" do
      proposal.update_attribute(:status, 'approved')  # skip state machine
      expect(ProposalPolicy).not_to permit(proposal.requester, proposal)
    end
  end

  permissions :can_cancel? do
    it "allows the requester to cancel it" do
      expect(ProposalPolicy).to permit(proposal.requester, proposal)
    end

    it "does not allow a requester to edit a cancelled one" do
      proposal.cancel!
      expect(ProposalPolicy).not_to permit(proposal.requester, proposal)
    end

    it "doesn't allow an approver to cancel it" do
      expect(ProposalPolicy).not_to permit(proposal.approvers[0], proposal)
    end

    it "allows admins to cancel" do
      admin = create(:user)
      admin.add_role("admin")
      expect(ProposalPolicy).to permit(admin, proposal)
    end
  end

  def proposal
    @_proposal ||= create(:proposal, :with_parallel_approvers, :with_observers)
  end
end
