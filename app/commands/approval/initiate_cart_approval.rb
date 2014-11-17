module Commands
  module Approval
    class InitiateCartApproval < Commands::Base
      def import_details(cart, params)
        cart.import_cart_properties(params['properties'])
        cart.import_cart_items(params['cartItems'])
        unless params['initiationComment'].blank?
          cart.import_initial_comments(params['initiationComment'])
        end
      end

      def setup_cart(params)
        cart = Cart.initialize_cart_with_items(params).reload
        if params['approvalGroup'].present?
          unless cart.approvals.any?
            cart.process_approvals_from_approval_group
          end
        else
          cart.process_approvals_without_approval_group(params)
        end

        self.import_details(cart, params)

        cart
      end

      def perform(params)
        cart = self.setup_cart(params)

        dispatcher = ParallelDispatcher.new
        dispatcher.deliver_new_cart_emails(cart)

        cart
      end
    end
  end
end
