class ActivityMailerPreview < ActionMailer::Preview
  def activity_notification
    ActivityMailer.activity_notification(user, proposal, activity)
  end

  private

  def activity
    "something happened!"
  end

  def user
    User.for_email("test@example.com")
  end

  def proposal
    Proposal.last
  end
end
