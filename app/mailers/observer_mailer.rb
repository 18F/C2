class ObserverMailer < ApplicationMailer
  def observer_added_notification(observation, reason)
    @observation = observation
    @reason = reason
    observer = observation.user
    @proposal = observation.proposal.decorate

    assign_threading_headers(@proposal)

    mail(
      to: email_to_user(observer),
      subject: subject(@proposal),
      from: observation_added_from(observation),
      reply_to: reply_email(@proposal)
    )
  end

  def observer_removed_notification(observation)
    @proposal = observation.proposal.decorate

    assign_threading_headers(@proposal)

    mail(
      to: email_to_user(observation.user),
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_complete(user, proposal)
    user = user
    @proposal = proposal.decorate

    assign_threading_headers(@proposal)

    mail(
      to: email_to_user(user),
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  private

  def observation_added_from(observation)
    adder = observation.created_by

    if adder
      user_email_with_name(adder)
    else
      default_sender_email
    end
  end
end
