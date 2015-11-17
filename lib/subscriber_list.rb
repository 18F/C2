class SubscriberList
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  # Returns triplets of (user, role name, observation)
  def triples
    requesters, approvers, observers = partitioned_roles
    requesters = requesters.map { |role| [role.user, "Requester", nil] }
    approvers = approvers.map { |role| [role.user, "Approver", nil] }
    observers = observers.map { |role| [role.user, nil, observation_for(role.user)] }

    requesters + approvers + observers
  end

  def users
    triples.map(&:first)
  end

  protected

  def partitioned_roles
    users = proposal.subscribers.sort_by(&:full_name)
    roles = users.map { |user| RolePicker.new(user, proposal) }

    requesters, roles = roles.partition(&:requester?)
    approvers, roles = roles.partition(&:approver?)
    observers = roles.select(&:observer?)

    [requesters, approvers, observers]
  end

  def observation_for(user)
    proposal.observations.find_by(user: user)
  end
end
