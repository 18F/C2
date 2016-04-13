module Oauth
  class ApplicationsController < Doorkeeper::ApplicationsController
    before_action :authenticate_user!

    def index
      @applications = current_user.oauth_applications
    end

    def create
      @application = Doorkeeper::Application.new(application_params)
      @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?
      if @application.save
        flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
        redirect_to oauth_application_url(@application)
      else
        render :new
      end
    end

    def authenticate_user!
      unless current_user
        flash[:error] = "You must login to access OAuth Applications"
        redirect_to "/"
      end
    end

    def current_user
      if session[:user] && session[:user]["email"]
        User.find_by(email_address: session[:user]["email"])
      end
    end
  end
end
