class StepMailer < ApplicationMailer
  def step_reply_received(step)
    @proposal = step.proposal.decorate
    @step = step
    @recipient = @proposal.requester
    add_inline_attachment("icon-page-circle.png")
    add_approval_chain_attachments(@proposal)
    assign_threading_headers(@proposal)

    send_email(
      to: @recipient,
      from: user_email_with_name(@step.user),
      proposal: @proposal
    )
  end

  def step_user_removed(user, proposal)
    @proposal = proposal.decorate
    @recipient = user
    add_inline_attachment("icon-pencil-circle.png")
    assign_threading_headers(@proposal)

    send_email(
      to: @recipient,
      from: user_email_with_name(@proposal.requester),
      proposal: @proposal
    )
  end

  def proposal_notification(step)
    @proposal = step.proposal.decorate
    @step = step.decorate
    @recipient = step.user
    add_proposal_attributes_icons(@proposal)
    add_inline_attachment("icon-page-circle.png")
    assign_threading_headers(@proposal)

    unless @step.api_token
      @step.create_api_token
    end

    send_email(
      to: @recipient,
      from: user_email_with_name(@proposal.requester),
      proposal: @proposal
    )
  end
end
