class LinearDispatcher < Dispatcher
  def next_pending_approval(proposal)
    # we don't care how the proposal was approved
    if proposal.pending?
      proposal.currently_awaiting_steps.first
    else
      nil
    end
  end

  def on_approval_approved(approval)
    if next_approval(approval)
      email_step_user(next_approval(approval))
    end

    super
  end

  private

  def next_approval(approval)
    next_pending_approval(approval.proposal)
  end
end
