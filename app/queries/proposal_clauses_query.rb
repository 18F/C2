class ProposalClausesQuery
  def for_client_slug(client_slug)
    namespace = client_slug.classify.constantize
    proposals[:client_data_type].matches("#{namespace}::%")
  end

  def which_involve(user)
    with_requester(user).or(
      with_approver_or_delegate(user).or(
        with_observer(user)
      )
    )
  end

  private

  def proposals
    Proposal.arel_table
  end

  def with_requester(user)
    proposals[:requester_id].eq(user.id)
  end

  def with_approver_or_delegate(user)
    Arel::Nodes::Exists.new(
      steps_for(user)
    )
  end

  def steps_for(user)
    approvals_with_delegates.where(
      with_matching_proposal.and(
        non_pending.and(
          where_step_user(user).or(where_delegate(user))
        )
      )
    ).ast
  end

  def approvals_with_delegates
    steps.project(Arel.star).
      join(delegates, Arel::Nodes::OuterJoin).
      on(delegates[:assigner_id].eq(steps[:user_id]))
  end

  def with_matching_proposal
    steps[:proposal_id].eq(proposals[:id])
  end

  def non_pending
    steps[:status].not_eq("pending")
  end

  def where_step_user(user)
    steps[:user_id].eq(user.id)
  end

  def where_delegate(user)
    delegates[:assignee_id].eq(user.id)
  end

  def with_observer(user)
    Arel::Nodes::Exists.new(
      observations_for(user)
    )
  end

  def steps
    Step.arel_table
  end

  def delegates
    UserDelegate.arel_table
  end

  def observations
    Observation.arel_table
  end

  def observations_for(user)
    observations.project(Arel.star).where(
      observations[:proposal_id].eq(proposals[:id]).and(
        observations[:user_id].eq(user.id)
      )
    ).ast
  end
end
