module Ncr
  class DashboardController < ApplicationController
    def index
      @rows = ClientDataCollectionDecorator.new(query).results
    end

    private

    def query
      NcrDashboardQuery.new(current_user).select_all
    end
  end
end
