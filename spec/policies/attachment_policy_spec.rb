describe AttachmentPolicy do
  subject { described_class }
  let(:proposal) {
    FactoryGirl.create(:proposal, :with_requester, :with_approvers,
                       :with_observers)
  }
  let(:attachment) { FactoryGirl.create(:attachment, proposal: proposal) } 

  permissions :can_destroy? do
    it "allows the original uploader to delete" do
      expect(subject).to permit(attachment.user, attachment)
    end

    it "does not allow anyone else to delete" do
      expect(subject).not_to permit(FactoryGirl.create(:user), attachment)
      expect(subject).not_to permit(proposal.requester, attachment)
      expect(subject).not_to permit(proposal.approvers.first, attachment)
      expect(subject).not_to permit(proposal.observers.first, attachment)
    end
  end
end
