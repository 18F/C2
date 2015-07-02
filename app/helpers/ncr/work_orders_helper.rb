module Ncr
  module WorkOrdersHelper
    def approver_options
      # @todo should this list be limited by client/something else?
      # @todo is there a better order? maybe by current_user's use?
      User.order(:email_address).pluck(:email_address)
    end

    # TODO split to multiple methods
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

      results = custom_buildings + known_buildings
      results.uniq!{|b| b[:value] }
      results.sort_by!{|b| b[:text] }
    end
  end
end
