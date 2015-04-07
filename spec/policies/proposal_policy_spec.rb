describe ProposalPolicy do
  subject { described_class }

  permissions :can_approve_or_reject? do
    context "parallel cart" do
      let(:proposal) {FactoryGirl.create(:proposal, :with_cart, :with_approvers,
                                         flow: 'parallel')}
      let(:approval) {proposal.approvals.first}

      it "allows when there's a pending approval" do
        proposal.approvers.each{ |approver|
          expect(subject).to permit(approver, proposal)
        }
      end

      it "does not allow when the user's already approved" do
        approval.update_attribute(:status, 'approved')  # skip state machine
        expect(subject).not_to permit(approval.user, proposal)
      end

      it "does not allow when the user's already rejected" do
        approval.update_attribute(:status, 'rejected')  # skip state machine
        expect(subject).not_to permit(approval.user, proposal)
      end

      it "does not allow with a non-existent approval" do
        user = FactoryGirl.create(:user)
        expect(subject).not_to permit(user, proposal)
      end
    end

    context "linear cart" do
      let(:proposal) {FactoryGirl.create(:proposal, :with_cart, :with_approvers,
                                         flow: 'linear')}
      let(:first_approval) {proposal.cart.approvals.first}
      let(:second_approval) {proposal.cart.approvals[1]}

      it "allows when there's a pending approval" do
        expect(subject).to permit(first_approval.user, proposal)
      end

      it "does not allow when it's not the user's turn" do
        user = proposal.approvers.last
        expect(subject).not_to permit(user, proposal)
      end

      it "does not allow when the user's already approved" do
        first_approval.update_attribute(:status, 'approved')  # skip state machine
        expect(subject).not_to permit(first_approval.user, proposal)
        expect(subject).to permit(second_approval.user, proposal)
      end

      it "does not allow when the user's already rejected" do
        first_approval.update_attribute(:status, 'rejected')  # skip state machine
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
    let(:proposal) {FactoryGirl.create(:proposal, :with_cart, :with_approvers,
                                       :with_requester, :with_observers)}

    it "allows the requester to see it" do
      expect(subject).to permit(proposal.requester, proposal)
    end

    it "allows an approver to see it" do
      expect(subject).to permit(proposal.approvers[0], proposal)
    end

    it "allows an observer to see it" do
      expect(subject).to permit(proposal.observers[0], proposal)
    end

    it "does not allow anyone else to see it" do
      expect(subject).not_to permit(FactoryGirl.create(:user), proposal)
    end
  end

  context "testing scope" do
    let(:proposal) {
      FactoryGirl.create(:proposal, :with_requester, :with_approvers,
                         :with_observers)}
    it "allows the requester to see" do
      user = proposal.requester
      proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
      expect(proposals).to include(proposal)
    end

    it "allows an requester to see, when there are no observers/approvers" do
      proposal = FactoryGirl.create(:proposal, :with_requester)
      user = proposal.requester
      proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
      expect(proposals).to include(proposal)
    end

    it "allows an approver to see" do
      user = proposal.approvers[0]
      proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
      expect(proposals).to include(proposal)
    end

    it "allows an observer to see" do
      user = proposal.approvers[0]
      proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
      expect(proposals).to include(proposal)
    end

    it "does not allow anyone else to see" do
      user = FactoryGirl.create(:user)
      proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
      expect(proposals).not_to include(proposal)
    end
  end
end
