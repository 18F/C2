class UsersController < ApplicationController
  include TokenAuth
  def update
    if params[:user] && params[:user][:update_beta_active] && current_user
      current_user.toggle_active_beta
    end
    redirect_to(:back)
  end
end
