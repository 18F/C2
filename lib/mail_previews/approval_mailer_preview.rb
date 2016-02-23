class ApprovalMalerPreivew < ActionMailer::Preview
  def approval_reply_received_email
    ApprovalMailer.approval_reply_received_email(received_approval)
  end

  private

  def received_approval
    Step.approved.last
  end
end
