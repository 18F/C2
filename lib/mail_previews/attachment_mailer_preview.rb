class AttachmentMailerPreview < ActionMailer::Preview
  def new_attachment_notification
    AttachmentMailer.new_attachment_notification(email, proposal, attachment)
  end

  private

  def email
    "recipient@example.com"
  end

  def proposal
    Proposal.last
  end

  def attachment
    Attachment.first
  end
end
