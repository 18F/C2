class MailPreview < MailView
  def approval_reply_received_email
    CommunicartMailer.approval_reply_received_email(Approval.last)
  end
end
