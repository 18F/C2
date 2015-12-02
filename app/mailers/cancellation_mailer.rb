class CancellationMailer < ApplicationMailer
  include ProposalConversationThreading

  layout "mailer"

  def cancellation_email(to_email, proposal, reason = nil)
    @reason = reason

    send_proposal_email(
      to_email: to_email,
      proposal: proposal,
    )
  end

  def cancellation_confirmation(proposal)
    send_proposal_email(
      to_email: proposal.requester.email_address,
      proposal: proposal
    )
  end

  def proposal_fiscal_cancellation(proposal)
    user = proposal.requester
    send_proposal_email(
      to_email: email_with_name(user.email_address, user.full_name),
      proposal: proposal,
    )
  end
end
