module ClientDataMixin
  extend ActiveSupport::Concern

  included do
    include FiscalYearMixin

    Proposal::CLIENT_MODELS << self

    has_paper_trail class_name: "C2Version"

    has_one :proposal, as: :client_data
    has_many :steps, through: :proposal
    has_many :individual_steps, -> { individual }, class_name: "Steps::Individual", through: :proposal
    has_many :approvers, through: :individual_steps, source: :user
    has_many :completers, through: :individual_steps, source: :completer
    has_many :observations, through: :proposal
    has_many :observers, through: :observations, source: :user
    has_many :comments, through: :proposal
    has_one :requester, through: :proposal

    accepts_nested_attributes_for :proposal

    validates :proposal, presence: true

    delegate(
      :add_observer,
      :add_requester,
      :currently_awaiting_approvers,
      :flow,
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
  end
end
