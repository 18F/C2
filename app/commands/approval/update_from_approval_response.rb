module Commands
  module Approval
    class UpdateFromApprovalResponse < Commands::Base
      def perform(params)
        target_cart = Cart.find_by(id: params[:cart_id].to_i)
        approval = target_cart.approvals.where(user_id: params[:user_id]).first
        action = params[:approver_action]
        mailer_params = {
          'approve' => params[:approver_action].upcase, #upcased to work with the current API. Refactoring to come.
          'fromAddress' => approval.user.email_address,
          'cartNumber' => target_cart.external_id
        }

        approval.update_attributes(status: mapped_attributes(action))
        approval.cart.update_approval_status
        CommunicartMailer.approval_reply_received_email(mailer_params, approval.cart).deliver
      end

      private

      def mapped_attributes action
        Cart::APPROVAL_ATTRIBUTES_MAP[action.to_sym]
      end

    end
  end
end
