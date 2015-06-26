module Ncr
  class WorkOrderPolicy < ProposalPolicy
    def initialize(user, record)
      super(user, record.proposal)
      @work_order = record
    end

    def restricted?
      ENV['RESTRICT_ACCESS'] == 'true'
    end

    def gsa_email?
      @user.email_address.end_with?('@gsa.gov')
    end

    def gsa!
      check(self.gsa_email?, "You must be logged in with a GSA email address to create")
    end

    def gsa_if_restricted!
      !self.restricted? || self.gsa!
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
