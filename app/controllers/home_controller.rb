class HomeController < ApplicationController
  # just to cut down on exception spam
  before_action :authenticate_user!, only: :error


  def index
    render(layout: false)
  end

  def error
    raise "test exception"
  end
end
