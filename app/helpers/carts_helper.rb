module CartsHelper
  # need to pass in the user because the current_user controller helper can't be stubbed
  # https://github.com/rspec/rspec-rails/issues/1076
  def display_status(cart, user)
    if cart.pending?
      approvers = cart.currently_awaiting_approvers
      if approvers.include?(user)
        content_tag('strong', "Please review")
      else
        names = approvers.map{|approver| approver.full_name }
        content_tag('em', "Waiting for review from:") + ' ' + names.join(', ')
      end
    else
      cart.status.titlecase
    end
  end

  def display_response_actions?(cart, user)
    return false unless user.approver_of? cart

    parallel_approval_is_pending?(cart, user) ||
    current_linear_approval?(cart, user)
  end

  # Move this to an NCR specific template?
  def display_restart?(cart, user)
    cart.ncr? && user == cart.requester && (cart.pending? || cart.rejected?)
  end

  def parallel_approval_is_pending?(cart, user)
    return false unless cart.parallel?
    if approval = Approval.find_by(cart_id: cart.id, user_id: user.id)
      approval.pending?
    else
      false
    end
  end

  def current_linear_approval?(cart, user)
    approval = Approval.find_by(cart_id: cart.id, user_id: user.id)
    cart.linear? && cart.ordered_awaiting_approvals.first == approval
  end


end
