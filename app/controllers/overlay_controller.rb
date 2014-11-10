class OverlayController < ApplicationController
  def index
    response.headers.delete('X-Frame-Options')
    render :layout => 'popup'
  end
end