class OverlayController < ApplicationController
  def index
    @hide_header = true
    response.headers.delete('X-Frame-Options')
  end
end