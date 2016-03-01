class ProposalMailer < ApplicationMailer
  layout "basic"
  add_template_helper ValueHelper

  def proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
    assign_threading_headers(proposal)

    mail(
      to: proposal.requester.email_address,
      subject: subject(proposal),
      from: default_sender_email,
      reply_to: reply_email(proposal)
    )
  end

  def emergency_proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
    assign_threading_headers(proposal)

    mail(
      to: proposal.requester.email_address,
      subject: subject(proposal),
      from: default_sender_email,
      reply_to: reply_email(proposal)
    )
  end

  def proposal_complete(proposal)
    @proposal = proposal.decorate
    assign_threading_headers(proposal)

    mail(
      to: proposal.requester.email_address,
      subject: subject(proposal),
      from: default_sender_email,
      reply_to: reply_email(proposal)
    )
  end

  def proposal_updated_step_complete_needs_re_review(step, modifier = nil)
    @step = step.decorate
    unless @step.api_token
      @step.create_api_token
    end
    @proposal = step.proposal.decorate
    @modifier = modifier || NullUser.new
    assign_threading_headers(@proposal)

    mail(
      to: step.user.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_updated_step_complete(step, modifier = nil)
    @proposal = step.proposal.decorate
    @modifier = modifier || NullUser.new
    assign_threading_headers(@proposal)

    mail(
      to: step.user.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  private

  def subject(proposal)
    "Request #{proposal.public_id}: #{proposal.name}"
  end
end
