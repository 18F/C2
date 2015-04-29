class ParallelDispatcher < Dispatcher
  def email_all_approvers(cart)
    cart.approvals.each do |approval|
      self.email_approver(approval)
    end
  end

  def deliver_new_proposal_emails(proposal)
    self.email_all_approvers(proposal.cart)
    super
  end
end
