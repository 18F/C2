class ProposalPolicy
  include TreePolicy

  def perm_trees
    {
      can_edit?: [:is_author?, :is_not_approved?],
      can_update?: [:can_edit?],
      can_approve_or_reject?: [:is_approver?, :is_pending_approver?]
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

  def is_approver?
    !@proposal.approvals.find_by(user: @user).nil?
  end

  def is_observer?
    @proposal.observers.include? @user
  end

  def is_pending_approver?
    actionable_approvers = @proposal.currently_awaiting_approvers
    actionable_approvers.include? @user
  end

  def can_approve_or_reject?
    self.test_all(:can_approve_or_reject?)
  end

  def can_edit?
    self.test_all(:can_edit?)
  end

  def can_update?
    self.can_edit?
  end

  def can_show?
    self.is_author? || self.is_approver? || self.is_observer?
  end

  # equivalent of can_show?
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @scope.joins(
        "LEFT JOIN approvals ON approvals.proposal_id = proposals.id",
        "LEFT JOIN observations ON observations.proposal_id = proposals.id"
      ).where(
        "requester_id = :user_id " +
        "or observations.user_id = :user_id " +
        "or approvals.user_id = :user_id", user_id: @user.id)
    end
  end
end
