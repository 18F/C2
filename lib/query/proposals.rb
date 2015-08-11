module Query
  class Proposals
    attr_reader :relation

    def initialize(relation = Proposal.all)
      @relation = relation
    end

    # note that this will leave out requests that the user is involved with *outside* of their specified client_slug
    def for_client_slug(client_slug)
      self.relation.where("client_data_type LIKE '#{client_slug.classify.constantize}::%'")
    end

    def which_involve(user)
      # use subselects instead of left joins to avoid an explicit
      # duplication-removal step
      where_clause = <<-SQL
        -- requester
        requester_id = :user_id
        -- approver / delegate
        OR EXISTS (
          SELECT * FROM approvals
          LEFT JOIN approval_delegates ON (assigner_id = user_id)
          WHERE proposal_id = proposals.id
            -- TODO make visible to everyone involved
            AND status <> 'pending'
            AND (user_id = :user_id OR assignee_id = :user_id)
        )
        -- observer
        OR EXISTS (SELECT id FROM observations
                   WHERE proposal_id = proposals.id AND user_id = :user_id)
      SQL

      self.relation.where(where_clause, user_id: user.id)
    end
  end
end
