class AttachmentMailer < ApplicationMailer
  def new_attachment_notification(user, proposal, attachment)
    @proposal = proposal.decorate
    @attachment = attachment
    @recipient = user
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("icon-clipped_page.png")
    assign_threading_headers(@proposal)

    send_email(
      to: @recipient,
      from: user_email_with_name(@attachment.user),
      proposal: @proposal
    )
  end
end
