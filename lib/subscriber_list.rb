class SubscriberList
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  # Returns triplets of (user, role name, observation)
  def triples
    requesters, approvers, others = self.partitioned_roles
    requesters = requesters.map { |r| [r.user, "Requester", nil] }
    approvers = approvers.map { |r| [r.user, "Approver", nil] }
    others = others.map { |r| [r.user, nil, self.proposal.observations.find_by(user: r.user)] }

    requesters + approvers + others
  end

  # sorted by how they should be displayed
  def users
    self.triples.map(&:first)
  end

  protected

  def partitioned_roles
    users = self.proposal.users.sort_by(&:full_name)
    roles = users.map { |u| Role.new(u, self.proposal) }

    requesters, roles = roles.partition(&:requester?)
    approvers, roles = roles.partition(&:approver?)
    observers = roles.select(&:observer?)

    [requesters, approvers, observers]
  end
end
