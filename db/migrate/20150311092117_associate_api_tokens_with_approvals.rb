class AssociateApiTokensWithApprovals < ActiveRecord::Migration
  def change
    add_reference :api_tokens, :approval

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE api_tokens
          SET approval_id = approvals.id
          FROM approvals, carts
          WHERE approvals.proposal_id = carts.proposal_id
            AND carts.id = api_tokens.cart_id
            AND api_tokens.user_id = approvals.user_id;
        SQL
      end

      dir.down do
        execute <<-SQL
          UPDATE api_tokens
          SET cart_id = carts.id, user_id = approvals.user_id
          FROM approvals, carts
          WHERE api_tokens.approval_id = approvals.id
            AND carts.proposal_id = approvals.proposal_id;
        SQL
      end
    end

    remove_reference :api_tokens, :cart
    remove_reference :api_tokens, :user
  end
end
