module Api
  module Ncr
    class WorkOrdersController < BaseController
      def index
        orders = ::Ncr::WorkOrder.order('created_at DESC')

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
