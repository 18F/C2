module Commands
  module Approval
    class InitiateCartApproval < Commands::Base
      def import_details(cart, params)
        unless params['properties'].blank?
          cart.set_props(params['properties'])
        end
        unless params['initiationComment'].blank?
          cart.import_initial_comments(params['initiationComment'])
        end
      end

      def setup_cart(params)
        cart = Cart.initialize_cart(params)
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
