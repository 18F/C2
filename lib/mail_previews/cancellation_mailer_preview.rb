class CancellationMailerPreview < ActionMailer::Preview
  def cancellation_email
    CancellationMailer.cancellation_email(email, proposal)
  end

  def cancellation_confirmation
    CancellationMailer.cancellation_confirmation(proposal)
  end

  def proposal_fiscal_cancellation
    CancellationMailer.proposal_fiscal_cancellation(proposal)
  end

  private

  def email
    "test@example.com"
  end

  def proposal
    Proposal.last
  end
end
