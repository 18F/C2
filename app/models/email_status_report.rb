class EmailStatusReport
  attr_accessor :cart

  def initialize(cart)
    @cart = cart
    @number_approved = @cart.approvals.where(status: 'approved').count
    @total_approvers = @cart.approvals.count
  end

  def generate_status_message
    if @number_approved == @total_approvers
      completed_status_message
    else
      progress_status_message
    end
  end

  def completed_status_message
    "All #{@number_approved} of #{@total_approvers} approvals have been received. Please move forward with the purchase  of Cart ##{@cart.external_id}."
  end

  def progress_status_message
    "#{@number_approved} of #{@total_approvers} approved."
  end
end
