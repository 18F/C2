class CancelationMailer < ApplicationMailer
  # TODO: Remove
  # rubocop:disable Metrics/MethodLength
  def cancelation_notification(recipient:, canceler:, proposal:, reason: nil)
    @reason = reason
    @user = canceler
    @proposal = proposal.decorate
    @recipient = recipient
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("button-x-circled.png")
    assign_threading_headers(@proposal)

    send_email(
      to: @recipient,
      from: user_email_with_name(@proposal.requester),
      proposal: @proposal
    )
  end

  def cancelation_confirmation(canceler:, proposal:, reason: nil)
    @reason = reason
    @proposal = proposal.decorate
    @recipient = canceler
    add_inline_attachment("button-x-circled.png")
    add_inline_attachment("icon-pencil-circle.png")
    assign_threading_headers(@proposal)

    send_email(to: @recipient, proposal: @proposal)
  end

  def fiscal_cancelation_notification(proposal)
    @proposal = proposal.decorate
    user = @proposal.requester
    @recipient = user
    add_inline_attachment("icon-pencil-circle.png")

    send_email(to: @recipient, proposal: @proposal)
  end
end
