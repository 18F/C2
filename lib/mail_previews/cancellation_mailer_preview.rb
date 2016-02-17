class CancellationMailerPreview < ActionMailer::Preview
  def cancellation_confirmation
    CancellationMailer.cancellation_confirmation(proposal)
  end

  private

  def proposal
    Proposal.last
  end
end
