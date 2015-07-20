class ApprovalManager
  attr_accessor :proposal

  delegate :api_tokens, :approvals, :linear?, :parallel?, to: :proposal

  def initialize(proposal)
    self.proposal = proposal
  end

  # Set the approver list, from any start state
  # This overrides the `through` relation but provides parity to the accessor
  def approvers=(approver_list)
    approvals = approver_list.each_with_index.map do |approver, idx|
      approval = self.proposal.existing_approval_for(approver)
      approval ||= Approval.new(user: approver, proposal: self.proposal)
      approval.position = idx + 1   # start with 1
      approval
    end
    self.proposal.approvals = approvals
    self.kickstart_approvals
    self.proposal.reset_status
  end

  # Trigger the appropriate approval, from any start state
  def kickstart_approvals()
    actionable = self.approvals.actionable
    pending = self.approvals.pending
    if self.parallel?
      pending.update_all(status: 'actionable')
    elsif self.linear? && actionable.empty? && pending.any?
      pending.first.make_actionable!
    end
    # otherwise, approvals are correct
  end

  def restart
    # Note that none of the state machine's history is stored
    self.api_tokens.update_all(expires_at: Time.now)
    self.approvals.update_all(status: 'pending')
    self.kickstart_approvals()
    Dispatcher.deliver_new_proposal_emails(self.proposal)
  end
end
