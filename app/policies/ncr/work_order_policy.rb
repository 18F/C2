module Ncr
  class WorkOrderPolicy < ProposalPolicy
    include GsaPolicy

    def initialize(user, record)
      super(user, record.proposal)
      @work_order = record
    end

    def not_cancelled!
      check(!@work_order.cancelled?, "The proposal is cancelled.")
    end

    def can_edit!
      check(self.requester? || self.approver? || self.observer?, "You must be the requester, approver, or observer to edit")
    end

    alias_method :can_update!, :can_edit!

    def can_create!
      super && self.gsa_if_restricted!
    end
    alias_method :can_new!, :can_create!
  end
end
