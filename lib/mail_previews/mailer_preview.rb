class MailerPreview < ActionMailer::Preview
  def actions_for_approver
    Mailer.actions_for_approver(pending_approval)
  end

  def proposal_observer_email
    Mailer.proposal_observer_email(email, proposal)
  end

  def approval_reply_received_email
    Mailer.approval_reply_received_email(received_approval)
  end

  private

  def pending_approval
    Steps::Approval.pending.last
  end

  def email
    "recipient@example.com"
  end

  def proposal
    Proposal.last
  end

  def received_approval
    Step.approved.last
  end
end
