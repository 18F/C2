class MakeCommentsOnlyReferenceProposals < ActiveRecord::Migration
  def change
    add_reference :comments, :proposal, index: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE comments
          SET proposal_id = carts.proposal_id
          FROM carts
          WHERE carts.id = commentable_id
            AND commentable_type = 'Cart';
        SQL
      end
      dir.down do
        execute <<-SQL
          UPDATE comments
          SET commentable_type = 'Cart',
              commentable_id = carts.id
          FROM carts
          WHERE comments.proposal_id = carts.proposal_id;
        SQL
      end
    end

    remove_reference :comments, :commentable, polymorphic: true
  end
end
