class ProposalServices
  def initialize

  end

  def create_new_observation(user, adder, reason, id)
    ObservationCreator.new(
      observer: user,
      proposal_id: id,
      reason: reason,
      observer_adder: adder
    ).run
  end
end
