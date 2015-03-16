class Proposal < ActiveRecord::Base
  include ThreeStateWorkflow

  workflow_column :status

  has_one :cart
  belongs_to :clientdata, polymorphic: true

  validates :flow, presence: true, inclusion: {in: ApprovalGroup::FLOWS}

  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :closed, -> { where(status: ['approved', 'rejected']) }

  after_initialize :set_defaults


  def set_defaults
    self.flow ||= 'parallel'
  end


  #### state machine methods ####
  # TODO remove dependence on Cart

  def on_pending_entry(prev_state, event)
    if self.cart.all_approvals_received?
      self.approve!
    end
  end

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

  ###############################
end
