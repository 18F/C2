class ObserverMailerPreview < ActionMailer::Preview
  include MailerPreviewHelpers

  def observer_added_notification
    ObserverMailer.observer_added_notification(observation, reason)
  end

  def observer_removed_notification
    ObserverMailer.observer_removed_notification(proposal, user)
  end

  def proposal_complete
    ObserverMailer.proposal_complete(user, completed_proposal)
  end

  private

  def observation
    Observation.last
  end

  def reason
    "I thought it was a good idea."
  end
end
