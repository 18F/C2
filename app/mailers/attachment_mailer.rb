class AttachmentMailer < ApplicationMailer
  def new_attachment_notification(to_email, proposal, attachment)
    @proposal = proposal.decorate
    @attachment_user = attachment.user
    @attachment = attachment
    assign_threading_headers(@proposal)

    mail(
      to: to_email,
      subject: subject(@proposal),
      from: user_email_with_name(@attachment_user),
      reply_to: reply_email(@proposal)
    )
  end
end
