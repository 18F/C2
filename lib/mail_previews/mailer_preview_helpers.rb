module MailerPreviewHelpers
  def canceled_proposal
    Proposal.canceled.last
  end

  def completed_proposal
    Proposal.completed.last || Proposal.last
  end

  def completed_step
    last_complete = Step.where(status: "completed").last
    if last_complete
      last_complete
    else
      stub = Step.last
      stub.status = "completed"
      stub
    end
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

  def new_user
    User.new(email_address: "newuser@test.com")
  end
end
