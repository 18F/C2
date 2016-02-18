class ObserverMailerPreview < ActionMailer::Preview
  def on_observer_added
    ObserverMailer.on_observer_added(observation, reason)
  end

  def proposal_observer_email
    ObserverMailer.proposal_observer_email(email, proposal)
  end

  private

  def observation
    Observation.last
  end

  def reason
    "I thought it was a good idea."
  end

  def email
    "test@example.com"
  end

  def proposal
    Proposal.last
  end
end
