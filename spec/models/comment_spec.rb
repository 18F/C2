describe Comment do
  describe "#listeners" do
    let (:proposal) { create(:proposal, :with_serial_approvers, :with_observers) }
    let (:comment) { create(:comment, proposal: proposal) }

    it "includes the requester" do
      expect(comment.listeners).to include(proposal.requester)
    end

    it "includes an observer" do
      expect(comment.listeners).to include(proposal.observers.first)
    end

    it "includes approved approvers" do
      individuals = proposal.individual_steps
      individuals += [Steps::Approval.new(user: create(:user))]
      proposal.root_step = Steps::Serial.new(child_steps: individuals)

      expect(proposal.approvers.length).to eq(3)
      proposal.individual_steps.first.complete!
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
