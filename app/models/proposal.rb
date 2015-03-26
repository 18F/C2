class Proposal < ActiveRecord::Base
  include ThreeStateWorkflow

  workflow_column :status

  has_one :cart
  has_many :approvals
  has_many :approval_users, through: :approvals, source: :user
  belongs_to :client_data, polymorphic: true
  # The following list also servers as an interface spec for client_datas
  delegate :fields_for_display, :client, :public_identifier, :total_price,
           :name, to: :client_data_legacy

  validates :flow, presence: true, inclusion: {in: ApprovalGroup::FLOWS}

  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :closed, -> { where(status: ['approved', 'rejected']) }

  after_initialize :set_defaults


  def set_defaults
    self.flow ||= 'parallel'
  end

  # Use this until all clients are migrated to models (and we no longer have a
  # dependence on "Cart"
  def client_data_legacy
    self.client_data || self.cart
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
    # self.cart.approver_approvals.where.not(status: 'approved').each do |approval|
    self.cart.approver_approvals.each do |approval|
      approval.restart!
    end
    Dispatcher.deliver_new_cart_emails(self.cart)
  end

  ###############################
end
