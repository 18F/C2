class CartsController < ApplicationController
  before_filter :authenticate_user!
  CLOSED_CART_LIMIT = 10

  def show
    cart = Cart.find params[:id]
    @cart = cart.decorate
    @proposal = cart.proposal
    @show_comments = true
  end

  def index
    # TODO: include action buttons for approvers
    @carts = current_user.carts.order('created_at DESC')
  end

  def archive
    @closed_cart_full_list = current_user.carts.closed.order('created_at DESC')
  end
end
