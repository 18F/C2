class StepMailerPreview < ActionMailer::Preview
  def step_reply_received
    StepMailer.step_reply_received(completed_step)
  end

  def step_user_removed
    StepMailer.step_user_removed(user, proposal)
  end

  def proposal_notification
    StepMailer.proposal_notification(step)
  end

  private

  def completed_step
    Step.where(status: "completed").last
  end

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
