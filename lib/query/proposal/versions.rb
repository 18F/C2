module Query
  module Proposal
    module Versions
      def self.container(proposal)
        config = TabularData::Container.config_for_client('versions', 'default')
        container = TabularData::Container.new(:versions, config)
        # TODO include versions from the related models
        container.alter_query { |rel| rel.where(item_id: proposal.id, item_type: 'Proposal') }
        container
      end
    end
  end
end
