class AssociateApiTokensWithApprovals < ActiveRecord::Migration
  def change
    add_reference :api_tokens, :approval

    reversible do |dir|
      # http://stackoverflow.com/a/6257679/358804

      dir.up do
        execute <<-SQL
          UPDATE api_tokens
          SET approval_id = approvals.id
          FROM approvals
          WHERE api_tokens.cart_id = approvals.cart_id AND api_tokens.user_id = approvals.user_id;
        SQL
      end

      dir.down do
        execute <<-SQL
          UPDATE api_tokens
          SET cart_id = approvals.cart_id, user_id = approvals.user_id
          FROM approvals
          WHERE api_tokens.approval_id = approvals.id;
        SQL
      end
    end

    remove_reference :api_tokens, :cart
    remove_reference :api_tokens, :user
  end
end
