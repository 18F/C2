class ObserverMailer < ApplicationMailer
  layout "mailer"
  add_template_helper ValueHelper

  def on_observer_added(observation, reason)
    @observation = observation
    @reason = reason
    observer = observation.user

    send_proposal_email(
      from_email: observation_added_from(observation),
      to_email: observer.email_address,
      proposal: observation.proposal
    )
  end

  def proposal_observer_email(to_email, proposal)
    send_proposal_email(
      to_email: to_email,
      proposal: proposal
    )
  end

  private

  def observation_added_from(observation)
    adder = observation.created_by

    if adder
      user_email_with_name(adder)
    end
  end
end
