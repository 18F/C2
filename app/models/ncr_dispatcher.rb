class NcrDispatcher < Dispatcher
  def on_proposal_update(modifier:, needs_review:)
    notify_approvers(modifier, needs_review)
    notify_pending_approvers(modifier)
    notify_requester(modifier, needs_review)
    notify_observers(modifier, needs_review)
  end

  private

  def requires_approval_notice?
    false
  end

  def notify_approvers(modifier, needs_review)
    proposal.individual_steps.approved.each do |step|
      unless user_is_modifier?(step.user, modifier)
        if needs_review == false
          ProposalMailer.
            proposal_updated_no_action_required(step.user, proposal, modifier).
            deliver_later
        end
      end
    end
  end

  def notify_requester(modifier, needs_review)
    if proposal.requester != modifier
      if needs_review == true
        ProposalMailer.proposal_updated_needs_re_review(proposal.requester, proposal, modifier).deliver_later
      else
        ProposalMailer.
          proposal_updated_no_action_required(proposal.requester, proposal, modifier).
          deliver_later
      end
    end
  end

  def notify_pending_approvers(modifier)
    proposal.currently_awaiting_steps.each do |step|
      unless user_is_modifier?(step.user, modifier)
        if step_user_already_notifier_about_proposal?(step)
          ProposalMailer.proposal_updated_while_step_pending(step).deliver_later
        else
          StepMailer.proposal_notification(step).deliver_later
        end
      end
    end
  end

  def notify_observers(modifier, needs_review)
    proposal.observers.each do |observer|
      unless user_is_modifier?(observer, modifier)
        if observer.role_on(proposal).active_observer?
          if needs_review == true
            ProposalMailer.proposal_updated_needs_re_review(observer, proposal, modifier).deliver_later
          else
            ProposalMailer.proposal_updated_no_action_required(observer, proposal, modifier).deliver_later
          end
        end
      end
    end
  end

  def user_is_modifier?(user, modifier)
    modifier && user == modifier
  end

  def step_user_already_notifier_about_proposal?(step)
    step.api_token.present?
  end
end
