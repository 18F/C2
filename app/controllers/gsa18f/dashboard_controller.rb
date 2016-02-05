module Gsa18f
  class DashboardController < ApplicationController
    def index
      @rows = ClientDataCollectionDecorator.new(query).results
    end

    private

    def query
      Gsa18f::DashboardQuery.new(current_user).select_all
    end
  end
end
