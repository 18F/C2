class CommentMailerPreview < ActionMailer::Preview
  include MailerPreviewHelpers

  def comment_added_notification
    CommentMailer.comment_added_notification(comment, email)
  end
end
