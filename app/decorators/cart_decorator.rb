class CartDecorator < Draper::Decorator
  delegate_all

  def total_price
    object.cart_items.reduce(0) do |sum,citem| sum + (citem.quantity * citem.price) end
  end

  def number_approved
    object.approvals.where(status: 'approved').count
  end

  def total_approvers
    object.approvals.count
  end


  def generate_status_message
    number_approved == total_approvers ? completed_status_message : progress_status_message
  end

  def completed_status_message
    "All #{number_approved} of #{total_approvers} approvals have been received. Please move forward with the purchase  of Cart ##{object.external_id}."
  end

  def progress_status_message
    "#{number_approved} of #{total_approvers} approved."
  end


end
