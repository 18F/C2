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
    flash[:success] = "You've updated your profile."
    redirect_to :profile
  end

  def beta
    user = current_user
    user.add_role(ROLE_BETA_USER)
    flash[:success] = "Your account is now enabled for beta access to new features!"
    redirect_to root_path
  end
end
