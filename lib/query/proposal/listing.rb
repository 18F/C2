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
        self.index_visible_container(:pending, filter: self.pending_filter).alter_query(&:pending)
      end

      def pending_review
        self.index_visible_container(:pending_review, filter: self.pending_review_filter).alter_query(&:pending)
      end

      def approved
        self.index_visible_container(:approved).alter_query(&:approved)
      end

      def cancelled
        self.index_visible_container(:cancelled).alter_query(&:cancelled)
      end

      def closed
        self.proposals_container(:closed).alter_query(&:closed)
      end

      def start_date
        @start_date ||= self.param_date(:start_date)
      end

      def end_date
        @end_date ||= self.param_date(:end_date)
      end

      def query
        proposals_data = self.query_container

        # @todo - move all of this filtering into the TabularData::Container object
        self.apply_date_filters(proposals_data)
        self.apply_text_filter(proposals_data)
        # TODO limit/paginate results

        proposals_data
      end

      protected

      def pending_filter
        Proc.new { |proposals| proposals.select { |p| !p.awaiting_approver?(self.user) } }
      end

      def pending_review_filter
        Proc.new { |proposals| proposals.select { |p| p.awaiting_approver?(self.user) } } 
      end

      def proposals_container(name, extra_config = {})
        config = TabularData::Container.config_for_client("proposals", self.user.client_slug)
        config = config.merge(extra_config)
        container = TabularData::Container.new(name, config)

        container.alter_query do |p|
          ProposalPolicy::Scope.new(self.user, p).resolve.includes(:client_data)
        end
        container.set_state_from_params(self.params)

        container
      end

      # returns a Container that is limited to what the user should see on /proposals, even if the ProposalPolicy::Scope allows them to see more
      def index_visible_container(name, config = {})
        container = self.proposals_container(name, config)
        container.alter_query do |rel|
          condition = Query::Proposal::Clauses.which_involve(self.user)
          rel.where(condition)
        end
      end

      def param_date(sym)
        begin
          Date.strptime(self.params[sym].to_s)
        rescue ArgumentError
          nil
        end
      end

      def query_container
        if self.params[:text]
          # only sort by the match priority if searching
          self.proposals_container(:query, frozen_sort: true)
        else
          self.proposals_container(:query)
        end
      end

      def apply_date_filters(proposals_data)
        if self.start_date
          proposals_data.alter_query { |p| p.where('proposals.created_at >= ?', self.start_date) }
        end
        if self.end_date
          proposals_data.alter_query { |p| p.where('proposals.created_at < ?', self.end_date) }
        end
      end

      def apply_text_filter(proposals_data)
        text = self.params[:text]
        if text
          proposals_data.alter_query do |p|
            Query::Proposal::Search.new(p).execute(text)
          end
        end
      end
    end
  end
end
