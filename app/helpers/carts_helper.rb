module CartsHelper
  # need to pass in the user because the current_user controller helper can't be stubbed
  # https://github.com/rspec/rspec-rails/issues/1076
  def display_status(cart, user)
    if cart.pending?
      if cart.parallel?
        approvers = cart.awaiting_approvers
        if approvers.include?(user)
          "Waiting for approval"
        else
          names = approvers.map{|approver| approver.full_name }
          "Waiting for approval from: #{names.join(', ')}"
        end
      else # linear
        approver = cart.ordered_awaiting_approvals.first.user
        if approver == user
          "Waiting for approval"
        else
          "Waiting for approval from: #{approver.full_name}"
        end
      end
    else
      cart.status.titlecase
    end
  end
end
