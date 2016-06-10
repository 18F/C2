class ProfileController < ApplicationController
  def show
  end

  def update
    user_params = params.require(:user)
    user = current_user
    user.first_name = user_params[:first_name]
    user.last_name = user_params[:last_name]
    user.timezone = user_params[:timezone] || User::DEFAULT_TIMEZONE
    user.save!
    flash[:success] = "Your profile is updated!"
    redirect_to :profile
  end
end
