class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    render(layout: false)
  end

  def error
    raise "test exception"
  end
end
