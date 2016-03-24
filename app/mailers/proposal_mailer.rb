class ProposalMailer < ApplicationMailer
  def emergency_proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
    add_proposal_attributes_icons(@proposal)
    add_inline_attachment("icon-truck-circle.png")
    assign_threading_headers(@proposal)

    mail(
      to: @proposal.requester.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_complete(proposal)
    @proposal = proposal.decorate
    add_inline_attachment("icon-check-green-circle.png")
    add_proposal_attributes_icons(@proposal)
    assign_threading_headers(@proposal)

    mail(
      to: @proposal.requester.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_created_confirmation(proposal)
    add_inline_attachment("icon-page-circle.png")
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: @proposal.requester.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_updated_no_action_required(user, proposal, comment)
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("button-circle.png")
    @proposal = proposal.decorate
    @modifier = comment.user
    @comment = comment
    assign_threading_headers(@proposal)

    mail(
      to: user.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_updated_needs_re_review(user, proposal, comment)
    @proposal = proposal.decorate
    add_proposal_attributes_icons(@proposal)
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("button-circle.png")
    @modifier = comment.user
    @comment = comment
    assign_threading_headers(@proposal)

    mail(
      to: user.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_updated_while_step_pending(step, comment)
    @proposal = step.proposal.decorate
    add_proposal_attributes_icons(@proposal)
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("button-circle.png")
    @step = step.decorate
    @modifier = comment.user
    @comment = comment
    assign_threading_headers(@proposal)

    unless @step.api_token
      @step.create_api_token
    end

    mail(
      to: step.user.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end
end
