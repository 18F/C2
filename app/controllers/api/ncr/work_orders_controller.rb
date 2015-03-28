module Api
  module Ncr
    class WorkOrdersController < ApplicationController
      # TODO add CORS support

      def index
        render json: ::Ncr::WorkOrder.all, root: false
      end
    end
  end
end
