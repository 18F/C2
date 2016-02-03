class Proposal < ActiveRecord::Base
  include WorkflowModel
  include ValueHelper
  include StepManager
  include Searchable
  include FiscalYearMixin

  has_paper_trail class_name: 'C2Version'

  CLIENT_MODELS = []  # this gets populated later

  workflow do
    state :pending do
      event :approve, transitions_to: :approved
      event :restart, transitions_to: :pending
      event :cancel, transitions_to: :cancelled
    end
    state :approved do
      event :restart, transitions_to: :pending
      event :cancel, transitions_to: :cancelled
      event :approve, transitions_to: :approved do
        halt  # no need to trigger a state transition
      end
    end
    state :cancelled do
      event :approve, transitions_to: :cancelled do
        halt  # can't escape
      end
    end
  end

  acts_as_taggable

  has_many :steps
  has_many :individual_steps, ->{ individual }, class_name: "Steps::Individual"
  has_many :approval_steps, class_name: "Steps::Approval"
  has_many :purchase_steps, class_name: "Steps::Purchase"
  has_many :step_users, through: :individual_steps, source: :user
  has_many :approvers, through: :approval_steps, source: :user
  has_many :purchasers, through: :purchase_steps, source: :user
  has_many :completers, through: :individual_steps, source: :completer
  has_many :api_tokens, through: :individual_steps
  has_many :attachments, dependent: :destroy
  has_many :user_delegates, through: :step_users, source: :outgoing_delegations
  has_many :comments, dependent: :destroy
  has_many :delegates, through: :user_delegates, source: :assignee

  has_many :observations, -> { where("proposal_roles.role_id in (select roles.id from roles where roles.name='observer')") }
  has_many :observers, through: :observations, source: :user
  belongs_to :client_data, polymorphic: true, dependent: :destroy
  belongs_to :requester, class_name: 'User'

  delegate :client_slug, to: :client_data, allow_nil: true

  validates :client_data_type, inclusion: {
    in: ->(_) { client_model_names },
    message: "%{value} is not a valid client model type. Valid client model types are: #{CLIENT_MODELS.inspect}",
    allow_blank: true
  }
  validates :requester_id, presence: true
  validates :public_id, uniqueness: true, allow_nil: true

  statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :closed, -> { where(status: ['approved', 'cancelled']) } #TODO: Backfill to change approvals in 'reject' status to 'cancelled' status
  scope :cancelled, -> { where(status: 'cancelled') }

  # elasticsearch indexing setup
  MAX_SEARCH_RESULTS = 20
  MAX_DOWNLOAD_ROWS = 10_000
  paginates_per MAX_SEARCH_RESULTS
  DEFAULT_INDEXED = {
    include: {
      client_data: {},
      comments: {
        include: {
          user: { methods: [:display_name], only: [:display_name] }
        }
      },
      steps: {
        include: {
          completed_by: { methods: [:display_name], only: [:display_name] }
        }
      },
      requester: {
        methods: [:display_name], only: [:display_name]
      }
    }
  }

  settings index: {
    number_of_shards: 1, # increase this if we ever get more than N records
    number_of_replicas: 1
  } do
    # with dynamic mapping==true, we only need to explicitly define overrides.
    # https://www.elastic.co/guide/en/elasticsearch/guide/current/dynamic-mapping.html
    # e.g., "amount" is explicitly declared to be numeric and not analyzed.
    # otherwise the first "amount" value that convince ES that the field should
    # be defined as an Integer (100), whereas it really ought to be a Float (100.00).
    # same thing for public_id: the first value ES sees might be an integer,
    # but the whole range of values in the db includes strings as well.
    mappings dynamic: "true" do
      indexes :id, boost: 2
      indexes :public_id, type: "string", index: :not_analyzed, boost: 1.5
      indexes :client_data_type, type: "string", index: :not_analyzed

      indexes :client_data do
        indexes :amount, type: "float"
      end
    end
  end

  def to_indexed_json(params = {})
    as_indexed_json(params).to_json
  end

  def as_indexed_json(params = {})
    as_json(params.reverse_merge(DEFAULT_INDEXED)).tap do |json|
      json[:subscribers] = subscribers.map { |user| { id: user.id, name: user.display_name } }
    end
  end

  def root_step
    steps.where(parent: nil).first
  end

  def parallel?
    root_step.type == "Steps::Parallel"
  end

  def serial?
    root_step.type == "Steps::Serial"
  end

  def delegate?(user)
    user_delegates.exists?(assignee_id: user.id)
  end

  def existing_step_for(user)
    where_clause = <<-SQL
      user_id = :user_id
      OR user_id IN (SELECT assigner_id FROM user_delegates WHERE assignee_id = :user_id)
      OR user_id IN (SELECT assignee_id FROM user_delegates WHERE assigner_id = :user_id)
    SQL

    steps.where(where_clause, user_id: user.id).first
  end

  def subscribers
    results = approvers + purchasers + observers + delegates + [requester]
    results.compact.uniq
  end

  def subscribers_except_delegates
    subscribers - delegates
  end

  def reset_status
    unless cancelled?
      if root_step.nil? || root_step.approved?
        update(status: "approved")
      else
        update(status: "pending")
      end
    end
  end

  def has_subscriber?(user)
    subscribers.include?(user)
  end

  def existing_observation_for(user)
    observations.find_by(user: user)
  end

  def eligible_observers
    if observations.count > 0
      User.where(client_slug: client_slug).where('id not in (?)', observations.pluck('user_id'))
    else
      User.where(client_slug: client_slug)
    end
  end

  def add_observer(email_address, adder=nil, reason=nil)
    user = User.for_email_with_slug(email_address, client_slug)

    # this authz check is here instead of in a Policy because the Policy classes
    # are applied to the current_user, not (as in this case) the user being acted upon.
    if client_data && !client_data.slug_matches?(user) && !user.admin?
      fail Pundit::NotAuthorizedError.new("May not add observer belonging to a different organization.")
    end

    unless existing_observation_for(user)
      create_new_observation(user, adder, reason)
    end
  end

  def add_requester(email)
    user = User.for_email(email)
    if awaiting_step_user?(user)
      fail "#{email} is an approver on this Proposal -- cannot also be Requester"
    end
    set_requester(user)
  end

  def set_requester(user)
    update(requester: user)
  end

  def name
    if client_data
      client_data.public_send(:name)
    end
  end

  def fields_for_display
    if client_data
      client_data.public_send(:fields_for_display)
    else
      []
    end
  end

  # Be careful if altering the identifier. You run the risk of "expiring" all
  # pending approval emails
  def version
    [
      updated_at.to_i,
      client_data.try(:version)
    ].compact.max
  end

  def restart
    individual_steps.each(&:restart!)

    if root_step
      root_step.initialize!
    end
    Dispatcher.deliver_new_proposal_emails(self)
  end

  # Returns True if the user is an "active" approver and has acted on the proposal
  def is_active_step_user?(user)
    individual_steps.non_pending.exists?(user: user)
  end

  def self.client_model_names
    CLIENT_MODELS.map(&:to_s)
  end

  def self.client_slugs
    CLIENT_MODELS.map(&:client_slug)
  end

  def self.client_model_for(user)
    CLIENT_MODELS.select { |cmodel| cmodel.slug_matches?(user) }[0]
  end

  private

  def create_new_observation(user, adder, reason)
    ObservationCreator.new(
      observer: user,
      proposal_id: id,
      reason: reason,
      observer_adder: adder
    ).run
  end
end
