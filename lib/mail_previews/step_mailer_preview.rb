class StepMailerPreview < ActionMailer::Preview
  def step_reply_received
    StepMailer.step_reply_received(step)
  end

  def step_user_removed
    StepMailer.step_user_removed(user, proposal)
  end

  def proposal_notification
    StepMailer.proposal_notification(step)
  end

  private

  def step
    Step.where(type: "Steps::Approval").last
  end

  def proposal
    Proposal.last
  end

  def user
    proposal.approvers.last
  end
end
