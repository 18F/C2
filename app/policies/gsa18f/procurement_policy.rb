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

    def can_cancel!
      not_cancelled! && check((approver? || delegate? || requester?) && !purchaser?, 
        "Sorry, you are neither the requester, approver or delegate")
    end

    protected

    def purchaser?
      @procurement.purchaser == @user
    end
  end
end
