module Query
  class Proposals
    attr_reader :relation

    # use subselects instead of left joins to avoid an explicit
    # duplication-removal step
    INVOLVES_WHERE_CLAUSE = <<-SQL
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

    def initialize(relation = Proposal.all)
      @relation = relation
    end

    # note that this will leave out requests that the user is involved with *outside* of their specified client_slug
    def for_client_slug(client_slug)
      namespace = client_slug.classify.constantize
      self.relation.where("client_data_type LIKE '#{namespace}::%'")
    end

    def which_involve(user)
      self.relation.where(INVOLVES_WHERE_CLAUSE, user_id: user.id)
    end
  end
end
