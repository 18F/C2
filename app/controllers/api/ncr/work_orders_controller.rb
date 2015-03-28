module Api
  module Ncr
    class WorkOrdersController < ApplicationController
      before_action :block_unless_enabled

      def index
        render json: ::Ncr::WorkOrder.all, root: false
      end


      private

      def block_unless_enabled
        unless ENV['API_ENABLED']
          raise ActionController::RoutingError.new('Not Found')
        end
      end
    end
  end
end
