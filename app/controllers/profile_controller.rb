class ProfileController < ApplicationController
  def show
  end

  def update
    first_name = params[:first_name]
    last_name = params[:last_name]
    user = current_user
    user.first_name = first_name
    user.last_name = last_name
    user.save!
    flash[:success] = "Your profile is updated!"
    redirect_to :me
  end
end
