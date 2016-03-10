require_relative "../chores/proposal_and_step_status_updater"

class ChangeStepsApprovedAtToCompletedAt < ActiveRecord::Migration
  def up
    rename_column :steps, :approved_at, :completed_at
    ProposalAndStepStatusUpdater.run
  end

  def down
    rename_column :steps, :completed_at, :approved_at
    ProposalAndStepStatusUpdater.unrun
  end
end
