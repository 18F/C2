describe ProposalPolicy do
  subject { described_class }

  permissions :can_approve? do
    it "allows pending delegates" do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)

      approval = proposal.individual_approvals.first
      delegate = FactoryGirl.create(:user)
      approver = approval.user
      approver.add_delegate(delegate)

      expect(subject).to permit(delegate, proposal)
    end

    context "parallel proposal" do
      let(:proposal) {FactoryGirl.create(:proposal, :with_parallel_approvers)}
      let(:approval) {proposal.individual_approvals.first}

      it "allows when there's a pending approval" do
        proposal.approvers.each{ |approver|
          expect(subject).to permit(approver, proposal)
        }
      end

      it "does not allow when the user's already approved" do
        approval.update_attribute(:status, 'approved')  # skip state machine
        expect(subject).not_to permit(approval.user, proposal)
      end

      it "does not allow with a non-existent approval" do
        user = FactoryGirl.create(:user)
        expect(subject).not_to permit(user, proposal)
      end
    end

    context "linear proposal" do
      let(:proposal) {FactoryGirl.create(:proposal, :with_serial_approvers)}
      let(:first_approval) { proposal.individual_approvals.first }
      let(:second_approval) { proposal.individual_approvals.last }

      it "allows when there's a pending approval" do
        expect(subject).to permit(first_approval.user, proposal)
      end

      it "does not allow when it's not the user's turn" do
        expect(subject).not_to permit(second_approval.user, proposal)
      end

      it "does not allow when the user's already approved" do
        first_approval.approve!
        expect(subject).not_to permit(first_approval.user, proposal)
        expect(subject).to permit(second_approval.user, proposal)
      end

      it "does not allow with a non-existent approval" do
        user = FactoryGirl.create(:user)
        expect(subject).not_to permit(user, proposal)
      end
    end
  end

  permissions :can_show? do
    let(:proposal) {FactoryGirl.create(:proposal, :with_parallel_approvers, :with_observers)}

    it "allows the requester to see it" do
      expect(subject).to permit(proposal.requester, proposal)
    end

    it "allows an approver to see it" do
      expect(subject).to permit(proposal.approvers[0], proposal)
      expect(subject).to permit(proposal.approvers[1], proposal)
    end

    it "does not allow a pending approver to see it" do
      first_approval = proposal.individual_approvals.first
      first_approval.update_attribute(:status, 'pending')
      expect(subject).not_to permit(first_approval.user, proposal)
      expect(subject).to permit(proposal.approvers.last, proposal)
    end

    it "allows an observer to see it" do
      expect(subject).to permit(proposal.observers[0], proposal)
    end

    it "does not allow anyone else to see it" do
      expect(subject).not_to permit(FactoryGirl.create(:user), proposal)
    end
  end

  permissions :can_edit? do
    let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers, :with_observers) }

    it "allows the requester to edit it" do
      expect(subject).to permit(proposal.requester, proposal)
    end

    it "doesn't allow an approver to edit it" do
      expect(subject).not_to permit(proposal.approvers[0], proposal)
      expect(subject).not_to permit(proposal.approvers[1], proposal)
    end

    it "doesn't allow an observer to edit it" do
      expect(subject).not_to permit(proposal.observers[0], proposal)
    end

    it "does not allow anyone else to edit it" do
      expect(subject).not_to permit(FactoryGirl.create(:user), proposal)
    end

    it "does not allow an approved request to be edited" do
      proposal.update_attribute(:status, 'approved')  # skip state machine
      expect(subject).not_to permit(proposal.requester, proposal)
    end
  end

  permissions :can_cancel? do
    let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers) }

    it "allows the requester to edit it" do
      expect(subject).to permit(proposal.requester, proposal)
    end

    it "does not allow a requester to edit a cancelled one" do
      proposal.cancel!
      expect(subject).not_to permit(proposal.requester, proposal)
    end

    it "doesn't allow an approver to cancel it" do
      expect(subject).not_to permit(proposal.approvers[0], proposal)
    end
  end
end
