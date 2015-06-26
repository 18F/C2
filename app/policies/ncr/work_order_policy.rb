module Ncr
  class WorkOrderPolicy < ProposalPolicy
    def initialize(user, record)
      super(user, record.proposal)
      @work_order = record
    end

    def can_edit!
      check(self.requester? || self.approver?, "You must be the requester or an approver to edit")
    end
    alias_method :can_update!, :can_edit!

    def can_create!
      # TODO feature flag
      super && check(@user.email_address.end_with?('@gsa.gov'), "You must be logged in with a GSA email address to create")
    end
    alias_method :can_new!, :can_create!
  end
end
