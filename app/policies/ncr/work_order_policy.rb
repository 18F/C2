module Ncr
  class WorkOrderPolicy < ProposalPolicy
    include GsaPolicy

    def initialize(user, record)
      super(user, record.proposal)
      @work_order = record
    end

    def restricted?
      ENV['RESTRICT_ACCESS'] == 'true'
    end

    def can_edit!
      check(self.requester? || self.approver?, "You must be the requester or an approver to edit")
    end
    alias_method :can_update!, :can_edit!

    def can_create!
      super && self.gsa_if_restricted!
    end
    alias_method :can_new!, :can_create!
  end
end
