module Commands
  module Approval
    class UpdateFromApprovalResponse < Commands::Base
      def perform(approval, new_status)
        approval.update_attributes(status: new_status)
        approval.cart.update_approval_status
        CommunicartMailer.approval_reply_received_email(approval).deliver
      end
    end
  end
end
