module Query
  module Proposal
    module Versions
      def self.relation(proposal)
        # TODO include versions from the related models
        C2Version.where(item_id: proposal.id, item_type: 'Proposal')
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
