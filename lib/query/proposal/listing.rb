module Query
  module Proposal
    class Listing
      attr_reader :params, :relation, :user

      def initialize(user, params, proposals = ::Proposal.all)
        @params = params
        @relation = proposals
        @user = user
      end

      def pending
        index_visible_container(:pending, filter: pending_filter).alter_query(&:pending)
      end

      def pending_review
        index_visible_container(:pending_review, filter: pending_review_filter).alter_query(&:pending)
      end

      def approved
        index_visible_container(:approved).alter_query(&:approved)
      end

      def cancelled
        index_visible_container(:cancelled).alter_query(&:cancelled)
      end

      def closed
        proposals_container(:closed).alter_query(&:closed)
      end

      def start_date
        @start_date ||= param_date(:start_date)
      end

      def end_date
        @end_date ||= param_date(:end_date)
      end

      def query
        proposals_data = query_container
        apply_date_filters(proposals_data)
        apply_text_filter(proposals_data)
        apply_status_filter(proposals_data)
        proposals_data
      end

      protected

      def pending_filter
        proc do |proposals|
          proposals.select { |proposal| !proposal.awaiting_step_user?(user) }
        end
      end

      def pending_review_filter
        proc do |proposals|
          proposals.select { |proposal| proposal.awaiting_step_user?(user) }
        end
      end

      def proposals_container(name, extra_config = {})
        config = TabularData::ContainerConfig.new("proposals", user.client_slug).settings
        config = config.merge(extra_config)
        container = TabularData::Container.new(name, config)

        container.alter_query do |proposal|
          ProposalPolicy::Scope.new(user, proposal).resolve.includes(:client_data)
        end
        container.set_state_from_params(params)

        container
      end

      # returns a Container that is limited to what the user should see on /proposals, even if the ProposalPolicy::Scope allows them to see more
      def index_visible_container(name, config = {})
        container = proposals_container(name, config)

        container.alter_query do |rel|
          condition = Query::Proposal::Clauses.new.which_involve(user)
          rel.where(condition)
        end
      end

      def param_date(sym)
        begin
          Date.strptime(params[sym].to_s)
        rescue ArgumentError
          nil
        end
      end

      def query_container
        if params[:text]
          # only sort by the match priority if searching
          proposals_container(:query, frozen_sort: true)
        else
          proposals_container(:query)
        end
      end

      def apply_date_filters(proposals_data)
        if start_date
          proposals_data.alter_query { |proposal| proposal.where("proposals.created_at >= ?", start_date) }
        end

        if end_date
          proposals_data.alter_query { |proposal| proposal.where("proposals.created_at < ?", end_date) }
        end
      end

      def apply_text_filter(proposals_data)
        if params[:text]
          proposals_data.alter_query do |proposal|
            Query::Proposal::Search.new(proposal).execute(params[:text])
          end
        end
      end

      def apply_status_filter(proposals_data)
        if params[:status]
          proposals_data.alter_query { |proposal| proposal.where(status: params[:status]) }
        end
      end
    end
  end
end
