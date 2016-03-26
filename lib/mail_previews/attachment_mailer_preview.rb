class AttachmentMailerPreview < ActionMailer::Preview
  include MailerPreviewHelpers

  def new_attachment_notification
    AttachmentMailer.new_attachment_notification(email, proposal, attachment)
  end

  private

  def attachment
    Attachment.last
  end
end
