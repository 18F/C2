class Proposal < ActiveRecord::Base
  include WorkflowModel
  include ProposalSteps
  include ProposalConfig
  include ValueHelper
  include StepManager
  include Searchable
  include FiscalYearMixin

  has_paper_trail class_name: "C2Version"

  CLIENT_MODELS = []  # this gets populated later

  workflow do
    state :pending do
      event :complete, transitions_to: :completed do
        if individual_steps.any?
          add_completed_comment
        end
      end
      event :restart, transitions_to: :pending
      event :cancel, transitions_to: :canceled
    end
    state :completed do
      event :restart, transitions_to: :pending
      event :cancel, transitions_to: :canceled
      event :complete, transitions_to: :completed do
        halt  # no need to trigger a state transition
      end
    end
    state :canceled do
      event :complete, transitions_to: :canceled do
        halt  # can't escape
      end
    end
  end

  acts_as_taggable
  visitable # Used to track user visit associated with processed proposal

  delegate :client_slug, to: :client_data, allow_nil: true

  validates :client_data_type, inclusion: {
    in: ->(_) { client_model_names },
    message: "%{value} is not a valid client model type. Valid client model types are: #{CLIENT_MODELS.inspect}",
    allow_blank: true
  }

  statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :closed, -> { where(status: ["completed", "canceled"]) }
  scope :canceled, -> { where(status: "canceled") }

  # elasticsearch indexing setup
  MAX_SEARCH_RESULTS = 20
  MAX_DOWNLOAD_ROWS = 10_000
  paginates_per MAX_SEARCH_RESULTS
  DEFAULT_INDEXED = PrepareProposalsElasticsearch.new.default_indexed

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
      indexes :client_slug, type: "string", index: :not_analyzed

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
      if client_data
        json[:client_data] = client_data.as_indexed_json
      end
      json[:client_slug] = self.client_slug
      json[:requester] = requester.display_name
      json[:subscribers] = index_subscribers(subscribers)
      json[:num_attachments] = attachments.count
    end
  end

  def index_subscribers(subscribers)
    subscribers.map { |user| { id: user.id, name: user.display_name } }
  end

  def add_restart_comment(user)
    fail("User required") unless user.is_a?(User)
    comments.create_without_callback(
      comment_text: I18n.t(
        "activerecord.attributes.proposal.user_restart_comment",
        user: user.full_name
      ),
      update_comment: true,
      user: user
    )
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

    DispatchFinder.run(self).deliver_new_proposal_emails
  end

  def fully_complete!(completer = nil, skip_notifications = false)
    individual_steps.each do |step|
      step.reload
      next if step.completed?
      step.skip_notifications = skip_notifications
      step.complete!
      if completer
        step.update(completer: completer)
      end
    end
    complete!
  end

  # Returns True if the user is an "active" step user and has acted on the proposal
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

  def completed_at_date
    if individual_steps.last.completed_at
      individual_steps.last.completed_at.to_s(:pretty_datetime)
    else
      "--"
    end
  end
end
