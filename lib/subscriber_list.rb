class SubscriberList
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  def triples
    requester_roles + approver_roles + purchaser_roles + observer_roles
  end

  private

  def requester_roles
    requesters.map { |role| [role.user, "Requester", nil] }
  end

  def approver_roles
    approvers.map { |role| [role.user, "Approver", nil] }
  end

  def purchaser_roles
    purchasers.map { |role| [role.user, "Purchaser", nil] }
  end

  def observer_roles
    observers.map { |role| [role.user, nil, observation_for(role.user)] }
  end

  def requesters
    @_requesters ||= roles.select(&:requester?)
  end

  def approvers
    @_approvers ||= roles.select(&:approver?)
  end

  def purchasers
    @_purchasers ||= roles.select(&:purchaser?)
  end

  def observers
    @_observers ||= roles.select(&:observer?)
  end

  def roles
    @_roles ||= sorted_users.map { |user| RolePicker.new(user, proposal) }
  end

  def sorted_users
    @_users ||= proposal.subscribers.sort_by(&:full_name)
  end

  def observation_for(user)
    proposal.observations.find_by(user: user)
  end
end
