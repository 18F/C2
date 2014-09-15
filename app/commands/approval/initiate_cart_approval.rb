module Commands
  module Approval
    class InitiateCartApproval < Commands::Base
      def perform(params)

        begin
          cart = Cart.initialize_cart_with_items(params).reload.decorate

          if !params['approvalGroup'].present?
            cart.process_approvals_without_approval_group(params)
          else
            cart.process_approvals_from_approval_group unless cart.approvals.any?
          end

          cart.import_cart_properties(params['properties'])
          cart.import_cart_items(params['cartItems'])
          cart.import_initial_comments(params['initiationComment']) unless params['initiationComment'].blank?
          cart.deliver_approval_emails

        rescue => error
          raise "Something went wrong: #{error}"
        end

      end
    end
  end
end