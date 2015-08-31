module Query
  module Proposal
    module Versions
      def self.models(proposal)
        [
          proposal,
          proposal.client_data,
          proposal.approvals,
          proposal.observations,
          proposal.comments.normal_comments,
          proposal.attachments
        ].flatten.compact
      end

      def self.relation(proposal)
        # TODO make query more efficient
        version_ids = self.models(proposal).map do |model|
          model.versions.pluck(:id)
        end
        version_ids.flatten!
        C2Version.where(id: version_ids)
      end

      def self.container(proposal)
        result = self.base_container
        result.alter_query { |rel| rel.merge(self.relation(proposal)) }
        result
      end

      protected

      def self.container_config
        TabularData::Container.config_for_client('versions', 'default')
      end

      def self.base_container
        TabularData::Container.new(:versions, self.container_config)
      end
    end
  end
end
