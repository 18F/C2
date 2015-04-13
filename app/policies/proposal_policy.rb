class ProposalPolicy
  include ExceptionPolicy
  def initialize(user, record)
    super(user, record)
    @proposal = record
  end

  def author!
    check(@proposal.requester_id == @user.id,
          "You are not the requester")
  end

  def not_approved!
    check(!@proposal.approved?,
          "That proposal's already approved. New proposal?")
  end

  def approver!
    check(!@proposal.approvals.find_by(user: @user).nil?,
          "Sorry, you're not an approver on this proposal")
  end

  def pending_approver!
    actionable_approvers = @proposal.currently_awaiting_approvers
    check(actionable_approvers.include?(@user),
          "You have already logged a response for this proposal")
  end

  def can_approve_or_reject!
    approver! && pending_approver!
  end

  def can_edit!
    author! && not_approved!
  end

  alias_method :can_update!, :can_edit!
end
