class CartsController < ApplicationController
  before_filter :authenticate_user!
  CLOSED_CART_LIMIT = 10

  def show
    cart = Cart.find params[:id]
    @cart = cart.decorate
    @show_comments = true
  end

  def index
    # TODO: handle role on a cart-by-cart basis
    # (including action buttons in approver/open case)
    @role = 'requester'
    @carts = current_user.carts.where(approvals: {role: @role})
    if @carts.empty?
      @role = 'approver'
      @carts = current_user.carts.where(approvals: {role: @role})
    end
  end

  def archive
    @role = params[:role] || 'requester'
    @closed_cart_full_list = current_user.carts.where(approvals: {role: @role}).closed
  end
end