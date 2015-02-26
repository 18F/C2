module ProposalDelegate
  extend ActiveSupport::Concern

  included do
    belongs_to :proposal

    validates :proposal, presence: true

    delegate(
      # TODO include Workflow states/events automatically
      :approve!,
      :approved?,
      :flow,
      :partial_approve!,
      :pending?,
      :reject!,
      :rejected?,
      :restart!,
      :status,

      to: :proposal
    )

    # effectively, delegate the scopes
    scope :with_proposal_scope, ->(status) { joins(:proposal).merge(Proposal.send(status)) }
    Proposal.statuses.each do |status|
      scope status, -> { with_proposal_scope(status) }
    end
    scope :closed, -> { with_proposal_scope(:closed) }

    accepts_nested_attributes_for :proposal
  end
end
