module Commands
  module Approval
    class UpdateFromApprovalResponse < Commands::Base
      def perform(approval, new_status)
        approval.update_attributes(status: new_status)
        approval.cart.update_approval_status

        Dispatcher.on_approval_status_change(approval)
      end
    end
  end
end
