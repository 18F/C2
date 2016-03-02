class ObserverMailer < ApplicationMailer
  layout "mailer"
  add_template_helper ValueHelper

  def observer_added_confirmation(observation, reason)
    @observation = observation
    @reason = reason
    observer = observation.user
    @proposal = observation.proposal.decorate

    assign_threading_headers(@proposal)

    mail(
      to: email_from_user(observer),
      subject: subject(@proposal),
      from: observation_added_from(observation),
      reply_to: reply_email(@proposal)
    )
  end

  def observer_added_notification(user, proposal)
    @proposal = proposal.decorate

    assign_threading_headers(proposal)

    mail(
      to: email_from_user(user),
      subject: subject(proposal),
      from: default_sender_email,
      reply_to: reply_email(proposal)
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
