class CommentMailer < ApplicationMailer
  include ProposalConversationThreading

  layout "mailer"

  def comment_added_email(comment, to_email)
    @comment = comment
    @proposal = comment.proposal

    unless @comment.update_comment
      send_proposal_email(
        from_email: user_email_with_name(comment.user),
        to_email: to_email,
        proposal: comment.proposal
      )
    end
  end
end
