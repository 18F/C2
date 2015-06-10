module Api
  module Ncr
    class WorkOrdersController < BaseController
      def index
        # TODO use a scope for ordering
        orders = ::Ncr::WorkOrder.
          includes(proposal: [:requester, approvals: [:user]]).
          order('proposals.created_at DESC')

        if params[:limit]
          orders = orders.limit(params[:limit].to_i)
        end
        if params[:offset]
          orders = orders.offset(params[:offset].to_i)
        end

        render json: orders, root: false
      end
    end
  end
end
