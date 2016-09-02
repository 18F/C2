class UsersController < ApplicationController
  include TokenAuth
  respond_to :js, only: [:update_list_view_config]
  def update
    if params[:user] && params[:user][:update_beta_active] && current_user
      current_user.toggle_active_beta
    end
    redirect_to(:back)
  end

  def update_list_view_config
    if params[:listViewConfig] && current_user
      current_user.list_view_config = params[:listViewConfig]
      current_user.save
    end
    respond_to do |format|
      format.js { render json: { listViewConfig: "success" } }
    end
  end
end
