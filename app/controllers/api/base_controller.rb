module Api
  class BaseController < ApplicationController
    before_action :fail_if_not_enabled
    before_action :doorkeeper_authorize!

    private

    def enable?
      ENV["API_ENABLED"] == "true"
    end

    def fail_if_not_enabled
      unless enable?
        render json: {error: 403, message: "Not authorized"}, status: 403
      end
    end

    def authenticate_user!
      if not_signed_in?
        render json: { error: "Authentication required" }, status: 401
      elsif current_user.deactivated?
        render json: { error: "Account deactivated" }, status: 403
      end
    end

    def check_disabled_client
      if client_disabled?
        render json: { error: "Client disabled" }, status: 403
      end
    end

    def auth_errors(exception)
      render json: { error: exception.message }, status: 403
    end
  end
end
