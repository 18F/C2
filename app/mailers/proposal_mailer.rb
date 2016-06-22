class ProposalMailer < ApplicationMailer
  def emergency_proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
    @recipient = @proposal.requester
    add_proposal_attributes_icons(@proposal)
    add_inline_attachment("icon-truck-circle.png")
    assign_threading_headers(@proposal)

    send_email(to: @recipient, proposal: @proposal)
  end

  def proposal_complete(proposal)
    @proposal = proposal.decorate
    @recipient = @proposal.requester
    add_inline_attachment("icon-check-green-circle.png")
    add_proposal_attributes_icons(@proposal)
    assign_threading_headers(@proposal)

    send_email(to: @recipient, proposal: @proposal)
  end

  def proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
    @recipient = @proposal.requester
    add_approval_chain_attachments(@proposal)
    add_inline_attachment("icon-page-circle.png")
    assign_threading_headers(@proposal)

    send_email(to: @recipient, proposal: @proposal)
  end

  def proposal_updated_no_action_required(user, proposal, comment)
    @proposal = proposal.decorate
    @modifier = comment.user
    @comment = comment
    @recipient = user
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("button-circle.png")
    assign_threading_headers(@proposal)

    send_email(to: @recipient, proposal: @proposal)
  end

  def proposal_updated_needs_re_review(user, proposal, comment)
    @proposal = proposal.decorate
    @modifier = comment.user
    @comment = comment
    @recipient = user
    add_proposal_attributes_icons(@proposal)
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("button-circle.png")
    assign_threading_headers(@proposal)

    send_email(to: @recipient, proposal: @proposal)
  end

  def proposal_updated_while_step_pending(step, comment)
    @proposal = step.proposal.decorate
    @step = step.decorate
    @modifier = comment.user
    @comment = comment
    @recipient = step.user
    add_proposal_attributes_icons(@proposal)
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("button-circle.png")
    assign_threading_headers(@proposal)

    @step.create_api_token unless @step.api_token

    send_email(to: @recipient, proposal: @proposal)
  end
end
