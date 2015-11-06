class RenameApprovalsUserProposalIdxToStepsUserProposalsIdx < ActiveRecord::Migration
  def change
    rename_index :steps, "approvals_user_proposal_idx", "steps_user_proposal_idx"
  end
end
