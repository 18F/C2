describe StepManager do
  describe "#add_step" do
    context "if steps have not yet been initialised on the proposal" do
      it "creates a new step series with the step" do
        proposal = create(:proposal)
        expect(proposal.steps).to be_empty
        new_step = create(:approval)
        proposal.add_step(new_step)

        aggregate_failures "testing steps" do
          expect(proposal.steps.first).to be_a Steps::Serial
          expect(proposal.steps.first.child_approvals.first).to eq new_step
          expect(proposal.steps.last).to eq new_step
        end
      end
    end

    context "if steps have been initialised on the proposal" do
      it "adds the step" do
        proposal = create(:proposal, :with_serial_approvers)
        new_step = create(:approval)
        proposal.add_step(new_step)
        aggregate_failures "testing steps" do
          expect(proposal.steps.first.child_approvals.last).to eq new_step
          expect(proposal.steps.last).to eq new_step
        end
      end
    end
  end
end
