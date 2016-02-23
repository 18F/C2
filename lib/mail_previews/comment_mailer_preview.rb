class CommentMailerPreview < ActionMailer::Preview
  def comment_added_notification
    CommentMailer.comment_added_notification(comment, email)
  end

  private

  def comment
    Comment.last
  end

  def email
    "recipient@example.com"
  end
end
