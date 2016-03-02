class ObserverMailer < ApplicationMailer
  def on_observer_added(observation, reason)
    @observation = observation
    @reason = reason
    observer = @observation.user
    @proposal =  observation.proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: observer.email_address,
      from: default_sender_email,
      subject: subject(@proposal),
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_observer_email(to_email, proposal)
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: to_email,
      from: default_sender_email,
      subject: subject(@proposal),
      reply_to: reply_email(@proposal)
    )
  end
end
