module ClientDataMixin
  extend ActiveSupport::Concern

  included do
    include FiscalYearMixin

    Proposal::CLIENT_MODELS << self

    has_paper_trail class_name: "C2Version"

    has_one :proposal, as: :client_data
    has_many :steps, through: :proposal
    has_many :individual_steps, -> { individual }, class_name: "Steps::Individual", through: :proposal
    has_many :observations, through: :proposal
    has_many :observers, through: :observations, source: :user
    has_many :comments, through: :proposal
    has_one :requester, through: :proposal
    has_many :completers, through: :proposal

    accepts_nested_attributes_for :proposal

    validates :proposal, presence: true

    delegate(
      :approvers,
      :purchasers,
      :add_observer,
      :add_requester,
      :currently_awaiting_step_users,
      :ineligible_approvers,
      :set_requester,
      :status,
      to: :proposal
    )

    scope :with_proposal_scope, ->(status) { joins(:proposal).merge(Proposal.send(status)) }
    scope :closed, -> { with_proposal_scope(:closed) }

    Proposal.statuses.each do |status|
      scope status, -> { with_proposal_scope(status) }
      delegate "#{status}?".to_sym, to: :proposal
    end

    Proposal.events.each do |event|
      delegate "#{event}!".to_sym, to: :proposal
    end

    def self.client_slug
      to_s.deconstantize.downcase
    end

    def client_slug
      self.class.client_slug
    end

    def slug_matches?(user)
      user.client_slug == client_slug
    end

    def self.slug_matches?(user)
      user.client_slug == self.client_slug
    end

    def self.expense_type_options
      []
    end

    def self.csv_headers
      column_names.sort.map { |attribute| human_attribute_name(attribute) }
    end

    def self.foreign_key_to_method_map
      @_fk_map ||= Hash[reflect_on_all_associations(:belongs_to).map { |a| [a.foreign_key, a.name] }]
    end

    def association_column?(column_name)
      self.class.foreign_key_to_method_map.key?(column_name)
    end

    def association_value(column_name)
      send(self.class.foreign_key_to_method_map[column_name])
    end

    def column_value(column_name)
      send(column_name)
    end

    def csv_fields
      field_values = []
      self.class.column_names.sort.each do |column_name|
        field_values << if association_column?(column_name)
                          association_value(column_name)
                        else
                          column_value(column_name)
                        end
      end
      field_values
    end

    def as_indexed_json
      as_json(include: self.class.foreign_key_to_method_map.values)
    end

    def initialize_steps
    end

    def self.permitted_params(_params, _client_data_instance)
    end

    def setup_and_email_subscribers(comment)
    end

    def normalize_input
    end
  end
end
