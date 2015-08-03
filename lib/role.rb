class Role 
  attr_accessor :role_type, :proposal, :user
  def initialize(user,proposal)
    self.user = user
    self.proposal = proposal
    self.set_role_type
  end

  def set_role_type
    role = ''
    if self.user == self.proposal.requester
      role = 'requester'
    elsif self.proposal.is_active_approver?(self.user)
      role = 'active approver'
    elsif self.proposal.observers.include?(self.user)
      role = 'observer'
    elsif self.proposal.approvers.include?(self.user)
      role = 'approver'
    end
    self.role_type = role
  end

  def approver?
    self.role_type == 'approver'
  end

  def active_approver?
    self.role_type == 'active approver'
  end

  def observer?
    self.role_type == 'observer'
  end

  def approver?
    self.role_type == 'approver'
  end
end