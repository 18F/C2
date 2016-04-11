class RolePicker
  attr_reader :user

  def initialize(user, proposal)
    @user = user
    @proposal = proposal
  end

  def observer_only?
    observer? && !active_step_user? && !requester?
  end

  def active_step_user?
    proposal.is_active_step_user?(user)
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

  def purchaser?
    proposal.purchasers.include?(user)
  end

  private

  attr_reader :proposal
end
