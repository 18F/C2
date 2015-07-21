class LinearDispatcher < Dispatcher
  def next_pending_approval(proposal)
    # we don't care how the proposal was approved
    if proposal.pending?
      proposal.currently_awaiting_approvals.first
    else
      nil
    end
  end

  def on_approval_approved(approval)
    if next_approval = self.next_pending_approval(approval.proposal)
      self.email_approver(next_approval)
    end
    super
  end
end
