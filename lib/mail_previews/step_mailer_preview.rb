class StepMailerPreview < ActionMailer::Preview
  def step_reply_received
    StepMailer.step_reply_received(received_approval)
  end

  def step_user_removed
    StepMailer.step_user_removed(to_email, proposal)
  end

  private

  def received_approval
    Step.where.not(user: nil).last
  end

  def proposal
    Proposal.last
  end

  def to_email
    "test@example.com"
  end
end
