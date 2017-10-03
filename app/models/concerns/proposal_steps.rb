module ProposalSteps
  extend ActiveSupport::Concern

  def delegate?(user)
    delegates.include?(user)
  end

  def existing_step_for(user)
    steps.find_by(user: user)
  end

  def existing_or_delegated_step_for(user)
    where_clause = ProposalServices.new(self).sql_for_step_user_or_delegate
    steps.find_by(where_clause, user_id: user.id)
  end

  def existing_or_delegated_actionable_step_for(user)
    where_clause = "(#{ProposalServices.new(self).sql_for_step_user_or_delegate}) AND status = :actionable"
    steps.where(sanitize_sql_array([where_clause, { user_id: user.id, actionable: :actionable }]))
  end

  def delegates
    ProposalQuery.new(self).delegates
  end

  def step_users
    ProposalQuery.new(self).step_users
  end

  def approvers
    ProposalQuery.new(self).approvers
  end

  def purchasers
    ProposalQuery.new(self).purchasers
  end

  def subscribers
    results = approvers + purchasers + observers + delegates + [requester]
    results.compact.uniq
  end

  def subscribers_except_future_step_users
    results = currently_awaiting_step_users + individual_steps.completed.map(&:user) + observers + [requester]
    results.compact.uniq
  end

  def subscribers_except_delegates
    subscribers - delegates
  end

  def subscriber?(user)
    subscribers.include?(user)
  end

  def existing_observation_for(user)
    observations.find_by(user: user)
  end

  def eligible_observers
    if observations.count.positive?
      User.where(client_slug: client_slug).where("id not in (?)", observations.pluck("user_id"))
    else
      User.where(client_slug: client_slug)
    end
  end

  def add_observer(user, adder = nil, reason = nil)
    # this authz check is here instead of in a Policy because the Policy classes
    # are applied to the current_user, not (as in this case) the user being acted upon.
    if client_data && !client_data.slug_matches?(user) && !user.admin?
      fail Pundit::NotAuthorizedError.new("May not add observer belonging to a different organization.")
    end

    unless existing_observation_for(user)
      ProposalServices.new(self).create_new_observation(user, adder, reason, id)
    end
  end

  def add_requester(email)
    user = User.for_email(email)
    if awaiting_step_user?(user)
      fail "#{email} is an approver on this Proposal -- cannot also be Requester"
    end
    set_requester(user)
  end

  def set_requester(user)
    update(requester: user)
  end

  def add_completed_comment
    completer = individual_steps.last.completed_by
    comments.create_without_callback(
      comment_text: I18n.t(
        "activerecord.attributes.proposal.user_completed_comment",
        user: completer.full_name
      ),
      update_comment: true,
      user: completer
    )
  end
end
