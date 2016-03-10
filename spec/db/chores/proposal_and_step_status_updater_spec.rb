require "#{Rails.root}/db/chores/proposal_and_step_status_updater"

describe ProposalAndStepStatusUpdater do
  describe ".run" do
    it "renames cancelled -> canceled for proposals" do
      proposal = build(:proposal, status: "cancelled")
      proposal.save(validate: false)

      ProposalAndStepStatusUpdater.run

      expect(proposal.reload.status).to eq "canceled"
    end

    it "renames approved -> completed for proposals" do
      proposal = build(:proposal, status: "approved")
      proposal.save(validate: false)

      ProposalAndStepStatusUpdater.run

      expect(proposal.reload.status).to eq "completed"
    end

    it "renames approved -> completed for steps" do
      step = build(:approval_step, status: "approved")
      step.save(validate: false)

      ProposalAndStepStatusUpdater.run

      expect(step.reload.status).to eq "completed"
    end
  end

  describe ".unrun" do
    it "renames canceled -> cancelled for proposals" do
      proposal = build(:proposal, status: "canceled")
      proposal.save(validate: false)

      ProposalAndStepStatusUpdater.unrun

      expect(proposal.reload.status).to eq "cancelled"
    end

    it "renames completed -> approved for proposals" do
      proposal = build(:proposal, status: "completed")
      proposal.save(validate: false)

      ProposalAndStepStatusUpdater.unrun

      expect(proposal.reload.status).to eq "approved"
    end

    it "renames completed -> approved for steps" do
      step = build(:approval_step, status: "completed")
      step.save(validate: false)

      ProposalAndStepStatusUpdater.unrun

      expect(step.reload.status).to eq "approved"
    end
  end
end
