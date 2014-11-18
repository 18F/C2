module Commands
  module Approval
    class UpdateFromApprovalResponse < Commands::Base
      def perform(approval, new_status)
        approval.update_attributes(status: new_status)
        approval.cart.update_approval_status

        dispatcher = ParallelDispatcher.new
        dispatcher.deliver_approval_email(approval)
      end
    end
  end
end
