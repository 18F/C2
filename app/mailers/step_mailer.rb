class StepMailer < ApplicationMailer
  def step_reply_received(step)
    add_approval_chain_attachments
    add_inline_attachment("icon-page-circle.png")
    @proposal = step.proposal.decorate
    assign_threading_headers(@proposal)
    @step = step
    @step_user = @step.user

    mail(
      to: @proposal.requester.email_address,
      subject: subject(@proposal),
      from: user_email_with_name(@step.user),
      reply_to: reply_email(@proposal)
    )
  end

  def step_user_removed(user, proposal)
    add_inline_attachment("icon-pencil-circle.png")
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: user.email_address,
      subject: subject(@proposal),
      from: user_email_with_name(@proposal.requester),
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_notification(step)
    add_approval_chain_attachments
    add_proposal_attributes_icons
    add_inline_attachment("icon-page-circle.png")
    @proposal = step.proposal.decorate
    assign_threading_headers(@proposal)
    @step = step.decorate

    unless @step.api_token
      @step.create_api_token
    end

    mail(
      to: step.user.email_address,
      subject: subject(@proposal),
      from: user_email_with_name(@proposal.requester),
      reply_to: reply_email(@proposal)
    )
  end
end
