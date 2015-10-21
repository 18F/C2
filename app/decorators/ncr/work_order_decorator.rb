module Ncr
  class WorkOrderDecorator < Draper::Decorator
    delegate_all

    EMERGENCY_APPROVER_EMAIL = 'Emergency - Verbal Approval'
    NO_APPROVER_FOUND = 'No Approver Found'

    def current_approver_email_address
      approver_email_address(current_approver)
    end

    def final_approver_email_address
      approver_email_address(final_approver)
    end

    def status_aware_approver_email_address
      if proposal.approved?
        final_approver_email_address
      else
        current_approver_email_address
      end
    end

    private

    def approver_email_address(approver)
      if approver
        approver.email_address
      elsif emergency
        EMERGENCY_APPROVER_EMAIL
      else
        NO_APPROVER_FOUND
      end
    end
  end
end
