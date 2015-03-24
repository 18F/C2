class CartDecorator < Draper::Decorator
  delegate_all

  def number_approved
    object.approved_approvals.count
  end

  def total_approvers
    object.approver_approvals.count
  end

  def approvals_by_status
    object.approver_approvals.order(
      # http://stackoverflow.com/a/6332081/358804
      <<-SQL
        CASE approvals.status
        WHEN 'approved' THEN 1
        WHEN 'rejected' THEN 2
        WHEN 'pending' THEN 3
        ELSE 4
        END
      SQL
    )
  end

  def approvals_in_list_order
    if object.flow == 'linear'
      object.ordered_approvals
    else
      self.approvals_by_status
    end
  end

  def display_status
    if cart.pending?
      'pending approval'
    else
      cart.status
    end
  end

  def generate_status_message
    if self.all_approvals_received?
      completed_status_message
    else
      progress_status_message
    end
  end

  def completed_status_message
    "All #{number_approved} of #{total_approvers} approvals have been received. Please move forward with the purchase  of Cart ##{object.proposal.client_data_legacy.public_identifier}."
  end

  def progress_status_message
    "#{number_approved} of #{total_approvers} approved."
  end

  # @TODO: remove in favor of client_partial or similar
  def cart_template_name
    origin_name = self.proposal.client_data_legacy.client
    if Cart::ORIGINS.include? origin_name
      "#{origin_name}_cart"
    else
      'cart_mail'
    end
  end

  def prefix_template_name
    if self.getProp('origin') == 'navigator'
      'navigator_prefix'
    else
      nil
    end
  end

end
