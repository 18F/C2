class ObserverMailerPreview < ActionMailer::Preview
  def observer_added_confirmation
    ObserverMailer.observer_added_confirmation(observation, reason)
  end

  def observer_removed_confirmation
    ObserverMailer.observer_removed_confirmation(observation)
  end

  private

  def observation
    Observation.last
  end

  def reason
    "I thought it was a good idea."
  end

  def user
    User.for_email("test@example.com")
  end

  def proposal
    Proposal.last
  end
end
