class ProposalServices
  def initialize(proposal)
    @proposal = proposal
  end

  def create_new_observation(user, adder, reason, id)
    ObservationCreator.new(
      observer: user,
      proposal_id: id,
      reason: reason,
      observer_adder: adder
    ).run
  end

  def sql_for_step_user_or_delegate
    <<-SQL
      user_id = :user_id
      OR user_id IN (SELECT assigner_id FROM user_delegates WHERE assignee_id = :user_id)
      OR user_id IN (SELECT assignee_id FROM user_delegates WHERE assigner_id = :user_id)
    SQL
  end
end
