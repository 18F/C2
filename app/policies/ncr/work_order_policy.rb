module Ncr
  class WorkOrderPolicy < ProposalPolicy
    def initialize(user, record)
      super(user, record.proposal)
      @work_order = record
    end

    def can_edit!
      requester!
    end
    alias_method :can_update!, :can_edit!
  end
end
