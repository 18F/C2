class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  skip_before_action :check_disabled_client

  def index
    render(layout: false)
  end

  def error
    raise "test exception"
  end
end
