class RolePicker
  attr_accessor :user
  GUARDS = {
    requester: ->(u, p) { u == p.requester },
    active_approver: ->(u, p) { p.is_active_approver? u },
    observer: ->(u, p) { p.observers.include? u },
    approver: ->(u, p) { p.approvers.include? u },
    client_admin: ->(u, p) { u.client_admin? && p.client == u.client_slug }
  }

  def initialize(user, proposal)
    @user = user
    @role_types = []
    GUARDS.each do |role, guard|
      if guard[user, proposal]
        @role_types << role
      end
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
