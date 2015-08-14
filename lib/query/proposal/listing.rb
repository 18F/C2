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
        self.proposals_container(:pending) { |p| p.pending }
      end

      def approved(limit)
        self.proposals_container(:approved) { |p| p.approved.limit(limit) }
      end

      def cancelled
        self.proposals_container(:cancelled) { |p| p.cancelled }
      end

      def closed
        self.proposals_container(:closed) { |p| p.closed }
      end

      def query
        text = self.params[:text]
        if text
          # only sort by the match priority if searching
          proposals_data = self.proposals_container(:query, frozen_sort: true)
        else
          proposals_data = self.proposals_container(:query)
        end

        # @todo - move all of this filtering into the TabularData::Container object
        start_date = self.parse_date(self.params[:start_date])
        end_date = self.parse_date(self.params[:end_date])

        if start_date
          proposals_data.alter_query{ |p| p.where('proposals.created_at >= ?', start_date) }
        end
        if end_date
          proposals_data.alter_query{ |p| p.where('proposals.created_at < ?', end_date) }
        end
        if text
          proposals_data.alter_query do |p|
            Query::Proposal::Search.new(p).execute(text)
          end
        end
        # TODO limit/paginate results

        proposals_data
      end

      protected

      def proposals_container(name, extra_config={}, &block)
        config = TabularData::Container.config_for_client("proposals", self.user.client_slug)
        config = config.merge(extra_config)
        container = TabularData::Container.new(name, config)
        container.alter_query { |p| ProposalPolicy::Scope.new(self.user, p).resolve.includes(:client_data) }
        if block
          container.alter_query(&block)
        end
        container.set_state_from_params(self.params)

        container
      end

      def parse_date(val)
        begin
          Date.strptime(val.to_s)
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
