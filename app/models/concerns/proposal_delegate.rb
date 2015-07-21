module ProposalDelegate
  extend ActiveSupport::Concern

  included do
    has_one :proposal, as: :client_data
    has_many :approvals, through: :proposal
    has_many :user_approvals, through: :proposal
    has_many :approvers, through: :approvals, source: :user
    has_many :observations, through: :proposal
    has_many :observers, through: :observations, source: :user
    has_many :comments, through: :proposal
    has_one :requester, through: :proposal

    accepts_nested_attributes_for :proposal

    validates :proposal, presence: true


    delegate :add_approver, :remove_approver, :add_observer, :add_requester, :set_requester, to: :proposal

    ### delegate the workflow actions/scopes/states ###

    scope :with_proposal_scope, ->(status) { joins(:proposal).merge(Proposal.send(status)) }
    scope :closed, -> { with_proposal_scope(:closed) }

    Proposal.statuses.each do |status|
      scope status, -> { with_proposal_scope(status) }
      delegate "#{status}?".to_sym, to: :proposal
    end

    Proposal.events.each do |event|
      delegate "#{event}!".to_sym, to: :proposal
    end

    delegate :flow, :status, to: :proposal

    ###################################################
  end
end
