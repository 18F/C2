class DeleteApprovalsWithoutProposals < ActiveRecord::Migration
  def up
    execute <<-SQL
      DELETE FROM approvals WHERE proposal_id is null;
    SQL
  end
end
