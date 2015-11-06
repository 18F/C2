class RenameApprovalsToSteps < ActiveRecord::Migration
  def change
    rename_table :approvals, :steps
    rename_column :api_tokens, :approval_id, :step_id
  end
end
