class AssociateApprovalsWithProposals < ActiveRecord::Migration
  def change
    add_reference :approvals, :proposal

    reversible do |dir|
      # http://stackoverflow.com/a/6257679/358804

      dir.up do
        execute <<-SQL
          UPDATE approvals
          SET proposal_id = proposals.id
          FROM carts
          -- get associated proposal through the cart
          LEFT OUTER JOIN proposals ON carts.proposal_id = proposals.id
          WHERE approvals.cart_id = carts.id;
        SQL
      end

      dir.down do
        execute <<-SQL
          UPDATE approvals
          SET cart_id = carts.id
          FROM proposals
          -- get associated cart through the proposal
          LEFT OUTER JOIN carts ON carts.proposal_id = proposals.id
          WHERE approvals.proposal_id = proposals.id;
        SQL
      end
    end

    remove_reference :approvals, :cart
  end
end
