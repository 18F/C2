class Role 
  def initialize(user,proposal)
    @role_types = []
    if user == proposal.requester
      @role_types << :requester
    end
    if proposal.is_active_approver?(user)
      @role_types << :active_approver
    end
    if proposal.observers.include?(user)
      @role_types << :observer
    end
    if proposal.approvers.include?(user)
      @role_types << :approver
    end
    if user.client_admin? && proposal.client == user.client_slug
      @role_types << :client_admin
    end
  end

  # Active Observer means, their main role is an observer
  def active_observer?
    self.observer? && !self.active_approver? && !self.requester?
  end

  # observer? approver? etc. get converted into scanning role_types
  def method_missing(method_sym, *arguments, &block)
    method_str = method_sym.to_s
    if method_str.end_with?("?")
      @role_types.include?(method_str[0..-2].to_sym)
    else
      super
    end
  end
end
