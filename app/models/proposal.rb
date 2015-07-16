class Proposal < ActiveRecord::Base
  include WorkflowModel
  include ValueHelper
  workflow do
    state :pending do
      # partial *may* trigger a full approval
      event :partial_approve, transitions_to: :approved, if: lambda { |p| p.all_approved? }
      event :partial_approve, transitions_to: :pending
      event :approve, :transitions_to => :approved
      event :restart, :transitions_to => :pending
      event :cancel, :transitions_to => :cancelled
    end
    state :approved do
      event :restart, :transitions_to => :pending
      event :cancel, :transitions_to => :cancelled
    end
    state :cancelled do
      event :partial_approve, :transitions_to => :cancelled
    end
  end

  has_one :cart
  has_many :approvals
  has_many :approvers, through: :approvals, source: :user
  has_many :api_tokens, through: :approvals
  has_many :attachments
  has_many :approval_delegates, through: :approvers, source: :outgoing_delegates
  has_many :comments
  has_many :observations
  has_many :observers, through: :observations, source: :user
  belongs_to :client_data, polymorphic: true
  belongs_to :requester, class_name: 'User'

  # The following list also servers as an interface spec for client_datas
  # Note: clients may implement:
  # :fields_for_display
  # :public_identifier
  # :version
  # Note: clients should also implement :version
  delegate :client, to: :client_data_legacy, allow_nil: true

  validates :flow, presence: true, inclusion: {in: ApprovalGroup::FLOWS}
  # TODO validates :requester_id, presence: true

  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :closed, -> { where(status: ['approved', 'cancelled']) } #TODO: Backfill to change approvals in 'reject' status to 'cancelled' status
  scope :cancelled, -> { where(status: 'cancelled') }

  after_initialize :set_defaults
  after_create :update_public_id


  def set_defaults
    self.flow ||= 'parallel'
  end

  def parallel?
    self.flow == 'parallel'
  end

  def linear?
    self.flow == 'linear'
  end

  def delegate?(user)
    self.approval_delegates.exists?(assignee_id: user.id)
  end

  def approval_for(user)
    where_clause = <<-SQL
      user_id = :user_id
      OR user_id IN (SELECT assigner_id FROM approval_delegates WHERE assignee_id = :user_id)
      OR user_id IN (SELECT assignee_id FROM approval_delegates WHERE assigner_id = :user_id)
    SQL
    self.approvals.where(where_clause, user_id: user.id).first
  end

  # Use this until all clients are migrated to models (and we no longer have a
  # dependence on "Cart"
  def client_data_legacy
    self.client_data || self.cart
  end

  # TODO convert to an association
  def delegates
    self.approval_delegates.map(&:assignee)
  end

  # Returns a list of all users involved with the Proposal.
  def users
    # TODO use SQL
    results = self.approvers + self.observers + self.delegates + [self.requester]
    results.compact
  end

  # returns the Approval
  def add_approver(email)
    user = User.for_email(email)
    approval = self.approvals.create!(user_id: user.id)
    approval
  end

  def remove_approver(email)
    user = User.for_email(email)
    approval = self.approval_for(user)
    approval.destroy
  end

  # Set the approver list, from any start state
  def approvers=(approver_list)
    approvals = approver_list.each_with_index.map do |approver, idx|
      approval = self.approval_for(approver)
      approval ||= Approval.new(user: approver, proposal: self)
      approval.position = idx + 1   # start with 1
      approval
    end
    self.approvals = approvals
    self.kickstart_approvals()
    self.reset_status()
  end

  # Trigger the appropriate approval, from any start state
  def kickstart_approvals()
    actionable = self.approvals.actionable
    pending = self.approvals.pending
    if self.parallel?
      pending.update_all(status: 'actionable')
    elsif self.linear? && actionable.empty? && pending.any?
      pending.first.make_actionable!
    end
    # otherwise, approvals are correct
  end

  def reset_status()
    if self.all_approved?
      self.update(status: 'approved')
    elsif self.approvals.rejected.any?
      self.update(status: 'rejected')
    else
      self.update(status: 'pending')
    end
  end

  def add_observer(email)
    user = User.for_email(email)
    if self.observations.where(user: user).empty?
      self.observations.create!(user_id: user.id)
    end
  end

  def add_requester(email)
    user = User.for_email(email)
    self.set_requester(user)
  end

  def set_requester(user)
    self.update_attributes!(requester_id: user.id)
  end

  def currently_awaiting_approvals
    self.approvals.actionable
  end

  def currently_awaiting_approvers
    self.approvers.merge(self.currently_awaiting_approvals)
  end

  # delegated, with a fallback
  # TODO refactor to class method in a module
  def delegate_with_default(method)
    data = self.client_data_legacy

    result = nil
    if data && data.respond_to?(method)
      result = data.public_send(method)
    end

    if result.present?
      result
    elsif block_given?
      yield
    else
      result
    end
  end


  ## delegated methods ##

  def public_identifier
    self.delegate_with_default(:public_identifier) { "##{self.id}" }
  end

  def name
    self.delegate_with_default(:name) {
      "Request #{self.public_identifier}"
    }
  end

  def fields_for_display
    # TODO better default
    self.delegate_with_default(:fields_for_display) { [] }
  end

  # Be careful if altering the identifier. You run the risk of "expiring" all
  # pending approval emails
  def version
    [
      self.updated_at.to_i,
      self.client_data_legacy.try(:version)
    ].compact.max
  end

  #######################


  def restart
    # Note that none of the state machine's history is stored
    self.api_tokens.update_all(expires_at: Time.now)
    self.approvals.update_all(status: 'pending')
    self.kickstart_approvals()
    Dispatcher.deliver_new_proposal_emails(self)
  end

  def all_approved?
    self.approvals.where.not(status: 'approved').empty?
  end

  # An approval has been approved. Mark the next as actionable
  # Note: this won't affect a parallel flow (as approvals start actionable)
  def partial_approve
    if next_approval = self.approvals.pending.first
      next_approval.make_actionable!
    end
  end

  protected
  def update_public_id
    self.update_attribute(:public_id, self.public_identifier)
  end
end
