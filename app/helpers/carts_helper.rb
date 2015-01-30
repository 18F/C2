module CartsHelper
  def display_status(cart)
    if cart.pending?
      names = cart.awaiting_approvals.map{|approval| approval.user.full_name }
      "Waiting for approval from: #{names.join(', ')}"
    else
      cart.status.titlecase
    end
  end
end
