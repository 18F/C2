module CartsHelper
  # need to pass in the user because the current_user controller helper can't be stubbed
  # https://github.com/rspec/rspec-rails/issues/1076
  def display_status(cart, user)
    if cart.pending?
      approvers = cart.currently_awaiting_approvers
      if approvers.include?(user)
        "Waiting for approval"
      else
        names = approvers.map{|approver| approver.full_name }
        "Waiting for approval from: #{names.join(', ')}"
      end
    else
      cart.status.titlecase
    end
  end
end
