module Api
  module Ncr
    class WorkOrdersController < ApplicationController
      def index
        orders = ::Ncr::WorkOrder.joins(:proposal).order('proposals.created_at DESC')

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
