class ProposalMailer < ApplicationMailer
  def proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: @proposal.requester.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def emergency_proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
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
    assign_threading_headers(@proposal)

    mail(
      to: @proposal.requester.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_updated_no_action_required(user, proposal, modifier = nil)
    @proposal = proposal.decorate
    @modifier = modifier || NullUser.new
    assign_threading_headers(@proposal)

    mail(
      to: user.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_updated_needs_re_review(user, proposal, modifier = nil)
    @proposal = proposal.decorate
    @modifier = modifier || NullUser.new
    # Example ideal data to consume
    @changes = [{verb: 'modified', result: 'this to that'},{verb: 'added', result: 'that'},{verb: 'modified', result: 'this to that'}]
    assign_threading_headers(@proposal)

    mail(
      to: user.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_updated_while_step_pending(step)
    @step = step.decorate
    @proposal = step.proposal.decorate
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
