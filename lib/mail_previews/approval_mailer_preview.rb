class ApprovalMalerPreivew < ActionMailer::Preview
  def approval_reply_received_email
    ApprovalMailer.approval_reply_received_email(received_approval)
  end

  def approver_removed
    ApprovalMailer.approver_removed(to_email, proposal)
  end

  private

  def received_approval
    Step.approved.last
  end

  def proposal
    Proposal.last
  end

  def to_email
    "test@example.com"
  end
end
