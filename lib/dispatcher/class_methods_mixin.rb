class Dispatcher
  module ClassMethodsMixin
    extend ActiveSupport::Concern

    class_methods do
      def initialize_dispatcher(proposal)
        if proposal.client_slug == "ncr"
          NcrDispatcher.new
        else
          LinearDispatcher.new
        end
      end

      def deliver_new_proposal_emails(proposal)
        dispatcher = initialize_dispatcher(proposal)
        dispatcher.deliver_new_proposal_emails(proposal)
      end

      def on_approval_approved(approval)
        dispatcher = initialize_dispatcher(approval.proposal)
        dispatcher.on_approval_approved(approval)
      end

      def on_comment_created(comment)
        dispatcher = initialize_dispatcher(comment.proposal)
        dispatcher.on_comment_created(comment)
      end

      def email_approver(approval)
        dispatcher = initialize_dispatcher(approval.proposal)
        dispatcher.email_approver(approval)
      end

      def on_proposal_update(proposal, modifier = nil)
        dispatcher = initialize_dispatcher(proposal)
        dispatcher.on_proposal_update(proposal, modifier)
      end

      def on_approver_removal(proposal, approvers)
        dispatcher = initialize_dispatcher(proposal)
        dispatcher.on_approver_removal(proposal, approvers)
      end

      def on_observer_added(observation, reason)
        dispatcher = initialize_dispatcher(observation.proposal)
        dispatcher.on_observer_added(observation, reason)
      end

      def deliver_attachment_emails(proposal)
        dispatcher = initialize_dispatcher(proposal)
        dispatcher.deliver_attachment_emails(proposal)
      end
    end
  end
end
