describe ProposalPolicy do
  subject { described_class }

  permissions :approve_reject? do
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
      let(:first_approval) {proposal.cart.ordered_approvals.first}
      let(:second_approval) {proposal.cart.ordered_approvals[1]}

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
end
