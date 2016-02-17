class CommentMailerPreview < ActionMailer::Preview
  def comment_added_email
    CommentMailer.comment_added_email(comment, email)
  end

  private

  def comment
    Comment.last
  end

  def email
    "recipient@example.com"
  end
end
