# @todo Eventually, delete
class CartsController < ApplicationController
  def show
    cart = Cart.find params[:id]
    redirect_to proposal_path(cart.proposal), status: :moved_permanently
  end

  def index
    redirect_to proposals_path, status: :moved_permanently
  end

  def archive
    redirect_to url_for(controller: 'proposals', action: 'archive'),
                status: :moved_permanently
  end
end
