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

  def notify_approvers(needs_review, comment)
    proposal.individual_steps.completed.each do |step|
      unless user_is_modifier?(step.user, comment.user)
        if needs_review == false
          ProposalMailer.
            proposal_updated_no_action_required(step.user, proposal, comment).
            deliver_later
        end
      end
    end
  end

  def notify_requester(needs_review, comment)
    if proposal.requester != comment.user
      if needs_review == true
        ProposalMailer.
          proposal_updated_needs_re_review(proposal.requester, proposal, comment).
          deliver_later
      else
        ProposalMailer.
          proposal_updated_no_action_required(proposal.requester, proposal, comment).
          deliver_later
      end
    end
  end

  def notify_pending_approvers(comment)
    proposal.currently_awaiting_steps.each do |step|
      unless user_is_modifier?(step.user, comment.user)
        if step_user_already_notifier_about_proposal?(step)
          ProposalMailer.proposal_updated_while_step_pending(step, comment).deliver_later
        else
          StepMailer.proposal_notification(step).deliver_later
        end
      end
    end
  end

  def notify_observers(needs_review, comment)
    proposal.observers.each do |observer|
      unless user_is_modifier?(observer, comment.user)
        if observer.role_on(proposal).active_observer?
          if needs_review == true
            ProposalMailer.
              proposal_updated_needs_re_review(observer, proposal, comment).
              deliver_later
          else
            ProposalMailer.
              proposal_updated_no_action_required(observer, proposal, comment).
              deliver_later
          end
        end
      end
    end
  end

  def user_is_modifier?(user, comment_user)
    user == comment_user
  end

  def step_user_already_notifier_about_proposal?(step)
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
