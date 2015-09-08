class Dispatcher
  module ClassMethodsMixin
    extend ActiveSupport::Concern

    class_methods do
      # todo: replace with dynamic dispatch
      def initialize_dispatcher(proposal)
        case proposal.flow
        when 'parallel'
          self.new
        when 'linear'
          # @todo: dynamic dispatch for selection
          if proposal.client == "ncr"
            NcrDispatcher.new
          else
            LinearDispatcher.new
          end
        end
      end

      # TODO DRY the following up

      def deliver_new_proposal_emails(proposal)
        dispatcher = self.initialize_dispatcher(proposal)
        dispatcher.deliver_new_proposal_emails(proposal)
      end

      def on_approval_approved(approval)
        dispatcher = self.initialize_dispatcher(approval.proposal)
        dispatcher.on_approval_approved(approval)
      end

      def on_comment_created(comment)
        dispatcher = self.initialize_dispatcher(comment.proposal)
        dispatcher.on_comment_created(comment)
      end

      def email_approver(approval)
        dispatcher = self.initialize_dispatcher(approval.proposal)
        dispatcher.email_approver(approval)
      end

      def on_proposal_update(proposal, modifier=nil)
        dispatcher = self.initialize_dispatcher(proposal)
        dispatcher.on_proposal_update(proposal, modifier)
      end

      def on_approver_removal(proposal, approvers)
        dispatcher = self.initialize_dispatcher(proposal)
        dispatcher.on_approver_removal(proposal, approvers)
      end

      def on_observer_added(observation)
        dispatcher = self.initialize_dispatcher(observation.proposal)
        dispatcher.on_observer_added(observation)
      end
    end
  end
end
