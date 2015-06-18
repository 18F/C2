class AddPublicIdToProposals < ActiveRecord::Migration
  def up
    add_column :proposals, :public_id, :string
    Proposal.find_each do |proposal|
      proposal.public_id = proposal.public_identifier
      proposal.save!
    end
  end

  def down
    remove_column :proposals, :public_id
  end
end
