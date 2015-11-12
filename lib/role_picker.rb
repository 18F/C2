class RolePicker
  attr_reader :user

  def initialize(user, proposal)
    @user = user
    @proposal = proposal
  end

  def active_observer?
    observer? && !active_approver? && !requester?
  end

  def active_approver?
    proposal.is_active_approver?(user)
  end

  def requester?
    user == proposal.requester
  end

  def observer?
    proposal.observers.include?(user)
  end

  def approver?
    proposal.approvers.include?(user)
  end

  private

  attr_reader :proposal
end
