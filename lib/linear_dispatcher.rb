class LinearDispatcher < Dispatcher
  def next_pending_approval(proposal)
    # we don't care how the proposal was approved/rejected
    if proposal.pending?
      proposal.currently_awaiting_approvals.first
    else
      nil
    end
  end

  def email_next_pending_approver(proposal)
    if approval = self.next_pending_approval(proposal)
      self.email_approver(approval)
    end
  end

  def deliver_new_proposal_emails(proposal)
    self.email_next_pending_approver(proposal)
    super
  end

  def on_approval_approved(approval)
    self.email_next_pending_approver(approval.proposal)
    super
  end
end
