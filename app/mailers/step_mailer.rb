class StepMailer < ApplicationMailer
  def step_reply_received(step)
    @proposal = step.proposal.decorate
    assign_threading_headers(@proposal)
    @step = step

    # Iterate through steps to find the LAST 'approved' person
    @proposal.individual_steps.each_with_index do |step, index|
      if step.status == 'approved'
        last_approved = User.find step.user_id
      end
    end
    @last_approved_user = last_approved_user

    mail(
      to: @proposal.requester.email_address,
      subject: subject(@proposal),
      from: user_email_with_name(@step.user),
      reply_to: reply_email(@proposal)
    )
  end

  def step_user_removed(to_email, proposal)
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: to_email,
      subject: subject(@proposal),
      from: user_email_with_name(@proposal.requester),
      reply_to: reply_email(@proposal)
    )
  end

  def proposal_notification(step)
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
