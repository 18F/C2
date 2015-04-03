class ProposalPolicy
  include TreePolicy

  def perm_trees
    {
      can_edit?: [:is_author?, :is_not_approved?],
      can_update?: [:can_edit?]
    }
  end

  def initialize(user, proposal)
    @user = user
    @proposal = proposal
  end

  def is_author?
    @proposal.requester_id == @user.id
  end

  def is_not_approved?
    !@proposal.approved?
  end

  def can_approve_reject?
    actionable_approvers = @proposal.currently_awaiting_approvers
    actionable_approvers.include? @user
  end

  def can_edit?
    self.test_all(:can_edit?)
  end

  def can_update?
    self.can_edit?
  end
end
