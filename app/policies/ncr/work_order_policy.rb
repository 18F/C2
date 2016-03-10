module Ncr
  class WorkOrderPolicy < ProposalPolicy
    include GsaPolicy

    def initialize(user, record)
      super(user, record.proposal)
      @work_order = record
    end

    def can_edit!
      check(
        requester? || step_user? || delegate? || observer?,
        t("errors.policies.ncr.work_order.can_edit")
      )
    end

    alias_method :can_update!, :can_edit!

    def can_create!
      super && gsa_if_restricted!
    end
    alias_method :can_new!, :can_create!
  end
end
