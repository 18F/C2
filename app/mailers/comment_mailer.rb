class CommentMailer < ApplicationMailer
  def comment_added_notification(comment, to_email)
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("icon-speech_bubble-blue.png")
    @comment = comment
    @proposal = comment.proposal
    @proposal = @proposal.decorate
    assign_threading_headers(@proposal)

    unless @comment.update_comment
      mail(
        to: to_email,
        subject: subject(@proposal),
        from: user_email_with_name(comment.user),
        reply_to: reply_email(@proposal)
      )
    end
  end
end
