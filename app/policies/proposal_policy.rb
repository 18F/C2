class ProposalPolicy
  include ExceptionPolicy
  def initialize(user, record)
    super(user, record)
    @proposal = record
  end

  def restricted?
    ENV['RESTRICT_ACCESS'] == 'true'
  end

  def requester?
    @proposal.requester_id == @user.id
  end

  def requester!
    check(self.requester?, "You are not the requester")
  end

  def not_approved!
    check(!@proposal.approved?,
          "That proposal's already approved. New proposal?")
  end

  def approver?
    @proposal.approvals.exists?(user: @user)
  end

  def delegate?
    @proposal.delegate?(@user)
  end

  def approver!
    check(self.approver? || self.delegate?,
          "Sorry, you're not an approver on this proposal")
  end

  def observer!
    check(@proposal.observers.include?(@user),
          "Sorry, you're not an observer on this proposal")
  end

  def pending_approver?
    @proposal.currently_awaiting_approvers.include?(@user)
  end

  def pending_delegate?
    ApprovalDelegate.where(assigner_id: @proposal.currently_awaiting_approvers, assignee: @user).exists?
  end

  def pending_approval!
    check(self.pending_approver? || self.pending_delegate?,
          "A response has already been logged a response for this proposal")
  end

  def can_approve_or_reject!
    approver! && pending_approval!
  end
  alias_method :can_approve!, :can_approve_or_reject!

  def can_edit!
    requester! && not_approved!
  end
  alias_method :can_update!, :can_edit!

  def can_show!
    visible = ProposalPolicy::Scope.new(@user, Proposal).resolve
    # TODO check via SQL
    check(visible.include?(@proposal), "You are not allowed to see this cart")
  end

  def can_create!
    # TODO restrict by client_slug
    true
  end
  alias_method :can_new!, :can_create!

  # equivalent of can_show?
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      # use subselects instead of left joins to avoid an explicit
      # duplication-removal step
      where_clause = <<-SQL
        -- requester
        requester_id = :user_id
        -- approver / delegate
        OR EXISTS (
          SELECT * FROM approvals
          LEFT JOIN approval_delegates ON (assigner_id = user_id)
          WHERE proposal_id = proposals.id
            -- TODO make visible to everyone involved
            AND status <> 'pending'
            AND (user_id = :user_id OR assignee_id = :user_id)
        )
        -- observer
        OR EXISTS (SELECT id FROM observations
                   WHERE proposal_id = proposals.id AND user_id = :user_id)
        SQL

      where_clause += " OR true" if @user.app_admin?
      where_clause += " OR client_data_type LIKE '#{@user.client_slug.classify.constantize}::%'" if @user.admin?

      @scope.where(where_clause, user_id: @user.id)
    end
  end
end
