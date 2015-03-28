module Api
  module Ncr
    class WorkOrdersController < ApplicationController
      def index
        orders = ::Ncr::WorkOrder.joins(:proposal).order('proposals.created_at DESC')
        render json: orders, root: false
      end
    end
  end
end
