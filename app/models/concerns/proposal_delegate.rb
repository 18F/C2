module ProposalDelegate
  extend ActiveSupport::Concern

  included do
    belongs_to :proposal
    has_many :approvals, through: :proposal
    has_many :approval_users, through: :approvals, source: :user

    accepts_nested_attributes_for :proposal

    validates :proposal, presence: true


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
