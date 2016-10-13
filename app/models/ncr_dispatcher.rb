class NcrDispatcher < Dispatcher
  def on_proposal_update(needs_review:, comment:)
    notify_approvers(needs_review, comment)
    notify_pending_approvers(comment)
    notify_requester(needs_review, comment)
    notify_observers(needs_review, comment)
  end

  private

  def requires_approval_notice?
    false
  end

  def user_is_modifier?(user, comment_user)
    user == comment_user
  end

  def step_user_already_notified_about_proposal?(step)
    step.api_token.present?
  end

  def deliver_proposal_created_confirmation
    if proposal.client_data.emergency?
      ProposalMailer.emergency_proposal_created_confirmation(proposal).deliver_later
    else
      ProposalMailer.proposal_created_confirmation(proposal).deliver_later
    end
  end
end
