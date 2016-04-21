class CommentMailer < ApplicationMailer
  def comment_added_notification(comment, user)
    @comment = comment
    @proposal = comment.proposal.decorate
    @recipient = user.is_a?(User) ? user : User.for_email(user)
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("icon-speech_bubble-blue.png")
    assign_threading_headers(@proposal)

    unless @comment.update_comment
      send_email(
        to: @recipient,
        from: user_email_with_name(@comment.user),
        proposal: @proposal
      )
    end
  end
end
