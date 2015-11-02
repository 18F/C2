class ProposalDecorator < Draper::Decorator
  delegate_all

  def number_approved
    object.individual_approvals.approved.count
  end

  def total_approvers
    object.individual_approvals.count
  end

  def approvals_by_status
    # Override default scope
    object.individual_approvals.with_users.reorder(
      # http://stackoverflow.com/a/6332081/358804
      <<-SQL
        CASE approvals.status
        WHEN 'approved' THEN 1
        WHEN 'actionable' THEN 2
        ELSE 3
        END
      SQL
    )
  end

  def approvals_in_list_order
    if object.flow == 'linear'
      object.individual_approvals.with_users
    else
      self.approvals_by_status
    end
  end

  def display_status
    if object.pending?
      'pending approval'
    else
      object.status
    end
  end

  def generate_status_message
    if object.approvals.non_pending.empty?
      progress_status_message
    else
      completed_status_message
    end
  end

  def completed_status_message
    "All #{number_approved} of #{total_approvers} approvals have been received. Please move forward with the purchase of ##{object.public_id}."
  end

  def progress_status_message
    "#{number_approved} of #{total_approvers} approved."
  end
end
