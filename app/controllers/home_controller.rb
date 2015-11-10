class HomeController < ApplicationController
  # just to cut down on exception spam
  before_action :authenticate_user!, only: :error


  def index
    render(layout: false)
  end

  def me
  end

  def edit_me
    first_name = params[:first_name]
    last_name = params[:last_name]
    user = current_user
    user.first_name = first_name
    user.last_name = last_name
    user.save!
    flash[:success] = "Your profile is updated!"
    redirect_to :me
  end

  def error
    raise "test exception"
  end
end
