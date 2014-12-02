class CartDecorator < Draper::Decorator
  delegate_all

  def total_price
    price = object.cart_items.reduce(0) do |sum,citem| sum + citem.quantity * citem.price end
    Float("%0.02f" % price)
  end

  def number_approved
    object.completed_approvals.count
  end

  def total_approvers
    object.approver_approvals.count
  end


  def display_status
    if cart.status == 'pending'
      'pending approval'
    else
      cart.status
    end
  end

  def generate_status_message
    if number_approved == total_approvers
      completed_status_message
    else
      progress_status_message
    end
  end

  def completed_status_message
    "All #{number_approved} of #{total_approvers} approvals have been received. Please move forward with the purchase  of Cart ##{object.external_id}."
  end

  def progress_status_message
    "#{number_approved} of #{total_approvers} approved."
  end

  def cart_template_name
    if self.getProp('origin') == 'navigator'
      'shared/navigator_cart'
    else
      'shared/cart_mail'
    end
  end

  def prefix_template_name
    if self.getProp('origin') == 'navigator'
      'shared/navigator_prefix'
    else
      nil
    end
  end
end
