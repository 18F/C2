class SplitApprovals < ActiveRecord::Migration
  class TempApproval < ActiveRecord::Base
    self.table_name = 'approvals'
  end

  class TempObservation < ActiveRecord::Base
    self.table_name = 'observations'
  end

  class TempProposal < ActiveRecord::Base
    self.table_name = 'proposals'
  end

  def change
    create_table :observations do |t|
      t.references :proposal
      t.references :user
      t.timestamps
    end
    add_column :proposals, :requester_id, :integer

    reversible do |dir|
      dir.up do
        TempApproval.where(role: 'observer').each do |approval|
          TempObservation.create!(
            proposal_id: approval.proposal_id,
            user_id: approval.user_id,
            created_at: approval.created_at,
            updated_at: approval.updated_at
          )

          approval.destroy!
        end

        TempProposal.reset_column_information

        TempApproval.where(role: 'requester').each do |approval|
          proposal = TempProposal.find(approval.proposal_id)
          proposal.requester_id = approval.user_id
          proposal.save!

          approval.destroy!
        end
      end

      dir.down do
        TempObservation.find_each do |observation|
          TempApproval.create!(
            role: 'observer',
            proposal_id: observation.proposal_id,
            user_id: observation.user_id,
            created_at: observation.created_at,
            updated_at: observation.updated_at
          )
        end

        TempProposal.find_each do |proposal|
          TempApproval.create!(
            role: 'requester',
            proposal_id: proposal.id,
            user_id: proposal.requester_id,
            created_at: proposal.created_at
            # note that updated_at will be incorrect
          )
        end
      end
    end

    remove_column :approvals, :role, :string
  end
end
