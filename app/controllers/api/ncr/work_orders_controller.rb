module Api
  module Ncr
    class WorkOrdersController < ApplicationController
      respond_to :json

      def index
        respond_with ::Ncr::WorkOrder.all
      end
    end
  end
end
