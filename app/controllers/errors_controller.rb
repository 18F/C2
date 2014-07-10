class ErrorsController < ApplicationController

  def token_authentication_error
    render :status => 489
  end
end
