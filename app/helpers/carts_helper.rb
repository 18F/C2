module CartsHelper

  def show_appropriate_approval_emails(cart, role, show_closed)
    emails = []
    if role == 'approver'
      cart.approvals.each do |approval|
        if approval.role != role
          emails.push(approval.user.email_address)
        end
      end
    else
      cart.approvals.each do |approval|
        # when we're a requester, if cart is closed, we show all emails. If not, we just show ones for which  we're awaiting response
        if approval.role != role && (show_closed || approval.status == 'pending')
          emails.push(approval.user.email_address)
        end
      end
    end
    emails
  end
end