class Proposal < ActiveRecord::Base
  include WorkflowModel
  include ValueHelper
  include StepManager

  has_paper_trail class_name: 'C2Version'

  CLIENT_MODELS = []  # this gets populated later
  FLOWS = %w(parallel linear).freeze

  workflow do
    state :pending do
      event :approve, :transitions_to => :approved
      event :restart, :transitions_to => :pending
      event :cancel, :transitions_to => :cancelled
    end
    state :approved do
      event :restart, :transitions_to => :pending
      event :cancel, :transitions_to => :cancelled
      event :approve, :transitions_to => :approved do
        halt  # no need to trigger a state transition
      end
    end
    state :cancelled do
      event :approve, :transitions_to => :cancelled do
        halt  # can't escape
      end
    end
  end

  has_many :steps
  has_many :individual_approvals, ->{ individual }, class_name: 'Steps::Individual'
  has_many :approvers, through: :individual_approvals, source: :user
  has_many :api_tokens, through: :individual_approvals
  has_many :attachments, dependent: :destroy
  has_many :approval_delegates, through: :approvers, source: :outgoing_delegations
  has_many :comments, dependent: :destroy
  has_many :delegates, through: :approval_delegates, source: :assignee

  has_many :observations, -> { where("proposal_roles.role_id in (select roles.id from roles where roles.name='observer')") }
  has_many :observers, through: :observations, source: :user
  belongs_to :client_data, polymorphic: true, dependent: :destroy
  belongs_to :requester, class_name: 'User'

  # The following list also servers as an interface spec for client_datas
  # Note: clients may implement:
  # :fields_for_display
  # :version
  # Note: clients should also implement :version
  delegate :client, to: :client_data, allow_nil: true

  validates :client_data_type, inclusion: {
    in: ->(_) { self.client_model_names },
    message: "%{value} is not a valid client model type. Valid client model types are: #{CLIENT_MODELS.inspect}",
    allow_blank: true
  }
  validates :flow, presence: true, inclusion: {in: FLOWS}
  validates :requester_id, presence: true
  validates :public_id, uniqueness: true, allow_nil: true

  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :closed, -> { where(status: ['approved', 'cancelled']) } #TODO: Backfill to change approvals in 'reject' status to 'cancelled' status
  scope :cancelled, -> { where(status: 'cancelled') }

  # @todo - this should probably be the only entry into the approval system
  def root_step
    self.steps.where(parent: nil).first
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

  def existing_approval_for(user)
    where_clause = <<-SQL
      user_id = :user_id
      OR user_id IN (SELECT assigner_id FROM approval_delegates WHERE assignee_id = :user_id)
      OR user_id IN (SELECT assignee_id FROM approval_delegates WHERE assigner_id = :user_id)
    SQL
    self.steps.where(where_clause, user_id: user.id).first
  end

  # Returns a list of all users involved with the Proposal.
  def users
    # TODO use SQL
    results = self.approvers + self.observers + self.delegates + [self.requester]
    results.compact.uniq
  end

  alias_method :subscribers, :users

  def root_step=(root)
    old_steps = self.steps.to_a
    step_list = root.pre_order_tree_traversal
    step_list.each { |a| a.proposal = self }
    self.steps = step_list
    # position may be out of whack, so we reset it
    step_list.each_with_index do |step, idx|
      step.set_list_position(idx + 1) # start with 1
    end

    self.clean_up_old_steps(old_steps, step_list)

    root.initialize!
    self.reset_status
  end

  def clean_up_old_steps(old_steps, step_list)
    # destroy any old steps that are not a part of step list
    (old_steps - step_list).each do |appr|
      appr.destroy if Step.exists?(appr.id)
    end
  end

  def reset_status()
    unless self.cancelled?   # no escape from cancelled
      if self.root_step.nil? || self.root_step.approved?
        self.update(status: 'approved')
      else
        self.update(status: 'pending')
      end
    end
  end

  def has_subscriber?(user)
    users.include?(user)
  end

  def existing_observation_for(user)
    observations.find_by(user: user)
  end

  def eligible_observers
    if observations.count > 0
      User.where(client_slug: client).where('id not in (?)', observations.pluck('user_id'))
    else
      User.where(client_slug: client)
    end
  end

  def add_observer(email_or_user, adder=nil, reason=nil)
    user = find_user(email_or_user)

    # this authz check is here instead of in a Policy because the Policy classes
    # are applied to the current_user, not (as in this case) the user being acted upon.
    if client_data && !client_data.slug_matches?(user)
      fail Pundit::NotAuthorizedError.new("May not add observer belonging to a different organization.")
    end

    unless existing_observation_for(user)
      create_new_observation(user, adder, reason)
    end
  end

  def add_requester(email)
    user = User.for_email(email)
    self.set_requester(user)
  end

  def set_requester(user)
    self.update_attributes!(requester_id: user.id)
  end

  # Approvals in which someone can take action
  def currently_awaiting_approvals
    self.individual_approvals.actionable
  end

  def currently_awaiting_approvers
    self.approvers.merge(self.currently_awaiting_approvals)
  end

  def awaiting_approver?(user)
    self.currently_awaiting_approvers.include?(user)
  end

  # delegated, with a fallback
  # TODO refactor to class method in a module
  def delegate_with_default(method)
    data = self.client_data

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

  def name
    self.delegate_with_default(:name) {
      "Request #{public_id}"
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
      self.client_data.try(:version)
    ].compact.max
  end

  #######################

  def restart
    # Note that none of the state machine's history is stored
    self.api_tokens.update_all(expires_at: Time.zone.now)
    self.steps.update_all(status: 'pending')
    if self.root_step
      self.root_step.initialize!
    end
    Dispatcher.deliver_new_proposal_emails(self)
  end

  # Returns True if the user is an "active" approver and has acted on the proposal
  def is_active_approver?(user)
    self.individual_approvals.non_pending.exists?(user_id: user.id)
  end

  def self.client_model_names
    CLIENT_MODELS.map(&:to_s)
  end

  def self.client_slugs
    CLIENT_MODELS.map(&:client)
  end

  protected

  def create_new_observation(user, adder, reason)
    ObservationCreator.new(
      observer: user,
      proposal_id: id,
      reason: reason,
      observer_adder: adder
    ).run
  end

  private

  def find_user(email_or_user)
    if email_or_user.is_a?(User)
      email_or_user
    else
      User.for_email_with_slug(email_or_user, client)
    end
  end
end
