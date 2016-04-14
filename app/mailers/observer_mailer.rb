class ObserverMailer < ApplicationMailer
  def observer_added_notification(observation, reason)
    @proposal = observation.proposal.decorate
    @observation = observation
    @reason = reason
    @recipient = observation.user
    add_proposal_attributes_icons(@proposal)
    add_inline_attachment("icon-page-circle.png")
    assign_threading_headers(@proposal)

    send_email(
      to: @recipient,
      from: observation_added_from(observation),
      proposal: @proposal
    )
  end

  def observer_removed_notification(proposal, user)
    @proposal = proposal.decorate
    @recipient = user
    add_inline_attachment("icon-pencil-circle.png")
    assign_threading_headers(@proposal)

    send_email(to: @recipient, proposal: @proposal)
  end

  def proposal_complete(user, proposal)
    @proposal = proposal.decorate
    @recipient = user
    add_proposal_attributes_icons(@proposal)
    add_inline_attachment("icon-check-green-circle.png")
    assign_threading_headers(@proposal)

    send_email(to: @recipient, proposal: @proposal)
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
