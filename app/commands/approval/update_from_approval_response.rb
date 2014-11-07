module Commands
  module Approval
    class UpdateFromApprovalResponse < Commands::Base
      def perform(params)
        target_cart = Cart.find_by(id: params[:cart_id].to_i)
        approval = target_cart.approvals.where(user_id: params[:user_id]).first
        action = params[:approver_action]

        approval.update_attributes(status: mapped_attributes(action))
        approval.cart.update_approval_status
        CommunicartMailer.approval_reply_received_email(approval).deliver
      end

      private

      def mapped_attributes action
        Cart::APPROVAL_ATTRIBUTES_MAP[action.to_sym]
      end

    end
  end
end
