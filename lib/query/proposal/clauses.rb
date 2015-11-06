# returns Arel nodes for composing in ActiveRecord queries
module Query
  module Proposal
    module Clauses
      def self.for_client_slug(client_slug)
        namespace = client_slug.classify.constantize
        proposals[:client_data_type].matches("#{namespace}::%")
      end

      def self.with_requester(user)
        proposals[:requester_id].eq(user.id)
      end

      def self.approvals_with_delegates
        approvals.project(Arel.star).
          join(delegates, Arel::Nodes::OuterJoin).
          on(delegates[:assigner_id].eq(approvals[:user_id]))
      end

      def self.with_approver_or_delegate(user)
        Arel::Nodes::Exists.new(
          self.approvals_for(user)
        )
      end

      def self.with_observer(user)
        Arel::Nodes::Exists.new(
          self.observations_for(user)
        )
      end

      def self.which_involve(user)
        self.with_requester(user).or(
          self.with_approver_or_delegate(user).or(
            self.with_observer(user)
          )
        )
      end

      protected

      def self.approvals
        Step.arel_table
      end

      def self.delegates
        ApprovalDelegate.arel_table
      end

      def self.observations
        Observation.arel_table
      end

      def self.proposals
        ::Proposal.arel_table
      end

      def self.with_matching_proposal
        approvals[:proposal_id].eq(proposals[:id])
      end

      def self.non_pending
        approvals[:status].not_eq('pending')
      end

      def self.where_approver(user)
        approvals[:user_id].eq(user.id)
      end

      def self.where_delegate(user)
        delegates[:assignee_id].eq(user.id)
      end

      ## subselects to be used alongside the proposals table ##
      # Subselects are used instead of left joins to avoid an explicit duplication-removal step.

      def self.approvals_for(user)
        self.approvals_with_delegates.where(
          self.with_matching_proposal.and(
            self.non_pending.and(
              self.where_approver(user).or(self.where_delegate(user))
            )
          )
        ).ast
      end

      def self.observations_for(user)
        observations.project(Arel.star).where(
          observations[:proposal_id].eq(proposals[:id]).and(
            observations[:user_id].eq(user.id)
          )
        ).ast
      end

      #########################################################
    end
  end
end
