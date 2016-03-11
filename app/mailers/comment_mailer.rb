class CommentMailer < ApplicationMailer
  def comment_added_notification(comment, to_email)
    @comment = comment
    @proposal = comment.proposal
    assign_threading_headers(@proposal)

    unless @comment.update_comment
      mail(
        to: to_email,
        subject: subject(@comment, @proposal),
        from: user_email_with_name(comment.user),
        reply_to: reply_email(@proposal)
      )
    end
  end

  private

  def subject(comment, proposal)
    "#{comment.user.full_name} added a comment to the request: #{proposal.name}"
  end
end
