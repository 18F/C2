module Commands
  module Approval
    class InitiateCartApproval < Commands::Base
      def import_details(cart, params)
        cart.import_cart_properties(params['properties'])
        unless params['cartItems'].blank?
          cart.import_cart_items(params['cartItems'])
        end
        unless params['initiationComment'].blank?
          cart.import_initial_comments(params['initiationComment'])
        end
      end

      def setup_cart(params)
        cart = Cart.initialize_cart_with_items(params)
        cart.save!

        # Reload needed because of caching of the associations.
        # TODO Remove need for this.
        cart.reload

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
        Dispatcher.deliver_new_cart_emails(cart)

        cart
      end
    end
  end
end
