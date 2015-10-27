describe StepManager do
  describe "#add_initial_step" do
    it "creates a new step series with the steps" do
      proposal = create(:proposal)
      expect(proposal.steps).to be_empty
      new_step1 = create(:approval)
      new_step2 = create(:approval)
      proposal.add_initial_steps([new_step1, new_step2])

      aggregate_failures "testing steps" do
        expect(proposal.steps.first).to be_a Steps::Serial
        expect(proposal.steps.first).to be_actionable
        expect(proposal.steps.first.child_approvals).to include(new_step1, new_step2)
        expect(proposal.steps.last).to eq new_step2
        expect(new_step1).to be_actionable
      end
    end
  end
end
