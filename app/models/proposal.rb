class Proposal < ActiveRecord::Base
  include WorkflowHelper::ThreeStateWorkflow

  workflow_column :status

  has_one :cart

  validates :flow, presence: true, inclusion: {in: ApprovalGroup::FLOWS}

  after_initialize :set_defaults


  def set_defaults
    self.flow ||= 'parallel'
  end

  # Used by the state machine
  def on_pending_entry(prev_state, event)
    if self.cart.all_approvals_received?
      self.approve!
    end
  end

  # Used by the state machine
  def on_rejected_entry(prev_state, event)
    if prev_state.name != :rejected
      Dispatcher.on_cart_rejected(self.cart)
    end
  end

  def restart
    # Note that none of the state machine's history is stored
    self.cart.api_tokens.update_all(expires_at: Time.now)
    self.cart.approver_approvals.each do |approval|
      approval.restart!
    end
    Dispatcher.deliver_new_cart_emails(self.cart)
  end
end
