class ProposalQuery
  def initialize(proposal)
    @proposal = proposal
  end

  def approvers
    User.joins(:steps).where(
      "steps.type = :step_type AND steps.proposal_id = :proposal_id",
      step_type: "Steps::Approval",
      proposal_id: proposal.id
    ).order("steps.position ASC")
  end

  def purchasers
    User.joins(:steps).where(
      "steps.type = :step_type AND steps.proposal_id = :proposal_id",
      step_type: "Steps::Purchase",
      proposal_id: proposal.id
    )
  end

  def step_users
    User.joins(:steps).where(
      "(steps.type = :purchase_step_type OR steps.type = :approval_step_type)
        AND steps.proposal_id = :proposal_id",
      purchase_step_type: "Steps::Purchase",
      approval_step_type: "Steps::Approval",
      proposal_id: proposal.id
    )
  end

  def delegates
    User.joins(:incoming_delegations).where(
      "user_delegates.assigner_id IN (:step_user_ids)",
      step_user_ids: step_users.pluck(:id)
    )
  end

  private

  attr_reader :proposal
end
