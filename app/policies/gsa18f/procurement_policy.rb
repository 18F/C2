module Gsa18f
  class ProcurementPolicy < ProposalPolicy
    include GsaPolicy

    def initialize(user, record)
      super(user, record.proposal)
      @procurement = record
    end

    def can_create!
      super && gsa_if_restricted!
    end
    alias_method :can_new!, :can_create!

    def can_cancel!
      not_canceled! && check(
        (approver? || delegate? || requester? || admin?) && !purchaser?,
        I18n.t("errors.policies.gsa18f.cancel_permission")
      )
    end
    alias_method :can_cancel_form!, :can_cancel!

    protected

    def purchaser?
      @procurement.purchaser == @user
    end

    def approver?
      @procurement.approvers.include?(@user)
    end
  end
end
