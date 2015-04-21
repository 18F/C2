module Api
  class BaseController < ApplicationController
    before_action :fail_if_not_enabled

    private

    def enable?
      signed_in? || ENV['PUBLIC_API_ENABLED'] == 'true'
    end

    def fail_if_not_enabled
      unless enable?
        render json: {error: 403, message: "Not authorized"}, status: 403
      end
    end
  end
end
