module Gsa18f
  class ProcurementPolicy < ProposalPolicy
    include GsaPolicy

    def initialize(user, record)
      super(user, record.proposal)
      @procurement = record
    end

    def can_create!
      super && self.gsa_if_restricted!
    end
    alias_method :can_new!, :can_create!
  end
end
