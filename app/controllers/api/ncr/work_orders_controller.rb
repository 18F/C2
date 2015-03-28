module Api
  module Ncr
    class WorkOrdersController < ApplicationController
      def index
        render json: ::Ncr::WorkOrder.all, root: false
      end
    end
  end
end
