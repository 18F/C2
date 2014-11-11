module Commands
  module Approval
    class InitiateCartApproval < Commands::Base
      def perform(params)
        cart = Cart.initialize_cart_with_items(params).reload.decorate
        if params['approvalGroup'].present?
          unless cart.approvals.any?
            cart.process_approvals_from_approval_group
          end
        else
          cart.process_approvals_without_approval_group(params)
        end

        cart.import_cart_properties(params['properties'])
        cart.import_cart_items(params['cartItems'])
        unless params['initiationComment'].blank?
          cart.import_initial_comments(params['initiationComment'])
        end
        cart.deliver_approval_emails

        cart.object
      end
    end
  end
end
