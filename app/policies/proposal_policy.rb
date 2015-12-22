class ProposalPolicy
  include ExceptionPolicy

  def initialize(user, record)
    super(user, record)
    @proposal = record
  end

  def can_approve!
    step_user! && pending_step! && not_cancelled!
  end

  def can_edit!
    (admin? || requester!) && not_approved! && not_cancelled!
  end

  alias_method :can_update!, :can_edit!

  def can_show!
    check(visible_proposals.exists?(@proposal.id), "You are not allowed to see this proposal")
  end

  alias_method :can_history!, :can_show!

  def can_create!
    slug_matches? || @user.admin?
  end
  alias_method :can_new!, :can_create!

  def can_cancel!
    (admin? || requester!) && not_cancelled!
  end
  alias_method :can_cancel_form!, :can_cancel!

  protected

  def use_case_namespace
    cls = self.class.to_s
    cls.gsub("::#{cls.demodulize}", '')
  end

  def slug_matches?
    use_case_namespace.downcase == @user.client_slug
  end

  def restricted?
    ENV['RESTRICT_ACCESS'] == 'true'
  end

  def requester?
    @proposal.requester_id == @user.id
  end

  def requester!
    check(requester?, "You are not the requester")
  end

  def not_approved!
    check(
      !@proposal.approved?,
      "That proposal's already approved. New proposal?"
    )
  end

  def not_cancelled!
    check(!@proposal.cancelled?, "Sorry, this proposal has been cancelled.")
  end

  def step_user?
    @proposal.approvers_and_purchasers.include?(@user) || @proposal.completers.exists?(@user.id)
  end

  def delegate?
    @proposal.delegate?(@user)
  end

  def admin?
    @user.admin?
  end

  def step_user!
    check(
      step_user? || delegate?,
      "Sorry, you're not an approver on this proposal"
    )
  end

  def observer!
    check(@proposal.observers.include?(@user),
          "Sorry, you're not an observer on this proposal")
  end

  def pending_step_user?
    @proposal.currently_awaiting_step_users.include?(@user)
  end

  def pending_delegate?
    ApprovalDelegate.where(assigner_id: @proposal.currently_awaiting_step_users, assignee: @user).exists?
  end

  def pending_step!
    check(pending_step_user? || pending_delegate?,
          "A response has already been logged for this proposal")
  end

  def visible_proposals
    ProposalPolicy::Scope.new(@user, Proposal).resolve
  end
end
