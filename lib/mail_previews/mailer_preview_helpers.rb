module MailerPreviewHelpers
  def canceled_proposal
    Proposal.canceled.last
  end

  def completed_proposal
    Proposal.completed.last
  end

  def completed_step
    Step.where(status: "completed").last
  end

  def comment
    Comment.normal_comments.last
  end

  def email
    "test@example.com"
  end

  def proposal
    Proposal.where.not(individual_steps: []).pending.last
  end

  def step
    Steps::Approval.last
  end

  def user
    User.last
  end
end
