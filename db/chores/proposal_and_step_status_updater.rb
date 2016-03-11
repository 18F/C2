class ProposalAndStepStatusUpdater
  def self.run
    self.new.run
  end

  def self.unrun
    self.new.unrun
  end

  def run
    proposal_canceled_query = "UPDATE proposals SET status = 'canceled' WHERE status = 'cancelled';"
    proposal_approved_query = "UPDATE proposals SET status = 'completed' WHERE status = 'approved';"
    step_approved_query = "UPDATE steps SET status = 'completed' WHERE status = 'approved';"
    run_queries(proposal_canceled_query, proposal_approved_query, step_approved_query)
  end

  def unrun
    proposal_canceled_query = "UPDATE proposals SET status = 'cancelled' WHERE status = 'canceled';"
    proposal_approved_query = "UPDATE proposals SET status = 'approved' WHERE status = 'completed';"
    step_approved_query = "UPDATE steps SET status = 'approved' WHERE status = 'completed';"
    run_queries(proposal_canceled_query, proposal_approved_query, step_approved_query)
  end

  private

  def run_queries(proposal_canceled_query, proposal_approved_query, step_approved_query)
    Proposal.connection.execute(proposal_canceled_query)
    Proposal.connection.execute(proposal_approved_query)
    Proposal.connection.execute(step_approved_query)
  end
end
