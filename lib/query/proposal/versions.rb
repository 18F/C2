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

      def self.version_ids_for(proposal)
        # TODO make query more efficient
        self.models(proposal).flat_map do |model|
          model.versions.pluck(:id)
        end
      end

      def self.container(proposal)
        result = self.base_container

        version_ids = self.version_ids_for(proposal)
        result.alter_query { |rel| rel.where(id: version_ids) }

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
