class Role 
  attr_accessor :role_types
  def initialize(user,proposal)
    self.set_role_types user, proposal
  end

  def set_role_types user, proposal
    roles = []
    if user == proposal.requester
      roles << :requester
    end
    if proposal.is_active_approver?(user)
      roles << :active_approver
    end
    if proposal.observers.include?(user)
      roles << :observer
    end
    if proposal.approvers.include?(user)
      roles << :approver
    end
    self.role_types = roles
  end

  def requester?
    self.role_types.include? :requester
  end
  def approver?
    self.role_types.include? :approver
  end

  # Active Approver means, their main role is as an approver
  # They're either the current approver who needs to approve
  # or they have already approved
  def active_approver?
    self.role_types.include? :active_approver
  end

  def observer?
    self.role_types.include? :observer
  end

  # Active Observer means, their main role is an observer
  def active_observer?
    self.role_types.include?(:observer) && !self.role_types.include?(:active_approver) && !self.role_types.include?(:requester)
  end

  def approver?
    self.role_types.include? :approver
  end
end