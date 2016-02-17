class ObserverMailerPreview < ActionMailer::Preview
  def on_observer_added
    ObserverMailer.on_observer_added(observation, reason)
  end

  private

  def observation
    Observation.last
  end

  def reason
    "I thought it was a good idea."
  end
end
