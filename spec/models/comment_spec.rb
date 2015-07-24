describe Comment do
  describe "#listeners" do
    let (:proposal) { FactoryGirl.create(:proposal, :with_serial_approvers, :with_observers) }
    let (:comment) { FactoryGirl.create(:comment, proposal: proposal) }

    it "includes the requester" do
      expect(comment.listeners).to include(proposal.requester)
    end

    it "includes an observer" do
      expect(comment.listeners).to include(proposal.observers.first)
    end

    it "includes approved approvers" do
      proposal.approvers = proposal.approvers + [FactoryGirl.create(:user)]
      expect(proposal.approvers.length).to eq(3)
      proposal.approvals.first.approve!
      expect(comment.listeners).to include(proposal.approvers[0])
      expect(comment.listeners).to include(proposal.approvers[1])
      expect(comment.listeners).not_to include(proposal.approvers[2])
    end

    it "does not include the comment creator" do
      proposal.requester = comment.user
      expect(comment.listeners).not_to include(proposal.requester)
    end
  end
end
