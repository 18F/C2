module Ncr
  module WorkOrdersHelper
    def building_options
      proposals = ProposalPolicy::Scope.new(current_user, Proposal).resolve
      proposals = proposals.where(client_data_type: 'Ncr::WorkOrder')
      # TODO make more efficient
      custom_buildings = proposals.map do |proposal|
        building_number = proposal.client_data.building_number
        {
          text: building_number,
          value: building_number
        }
      end

      known_buildings = Ncr::Building.all.map do |building|
        {
          text: building.to_s,
          value: building.number
        }
      end

      custom_buildings + known_buildings
    end
  end
end
