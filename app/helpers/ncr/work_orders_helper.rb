module Ncr
  module WorkOrdersHelper
    def approver_options
      # @todo should this list be limited by client/something else?
      # @todo is there a better order? maybe by current_user's use?
      User.order(:email_address).pluck(:email_address)
    end

    def user_building_options
      proposals = Ncr::WorkOrderPolicy::Scope.new(current_user).resolve
      work_orders = Ncr::WorkOrder.joins(:proposal).merge(proposals)
      building_numbers = work_orders.pluck('DISTINCT building_number')

      building_numbers.map do |building_number|
        {
          text: building_number,
          value: building_number
        }
      end
    end

    def predefined_building_options
      Ncr::Building.all.map do |building|
        {
          text: building.to_s,
          value: building.number
        }
      end
    end

    def building_options
      results = user_building_options + predefined_building_options
      results.uniq!{|b| b[:value] }
      results.sort_by!{|b| b[:text] }
    end
  end
end
