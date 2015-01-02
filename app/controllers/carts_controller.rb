class CartsController < ApplicationController
  before_filter :authenticate_user!
  CLOSED_CART_LIMIT = 10

  def show
    cart = Cart.find params[:id]
    @cart = cart.decorate
    @show_comments = true
  end

  def index
    @role = 'requester'
    my_carts = current_user.carts.where(approvals: {role: @role})
    if my_carts.empty?
      @role = 'approver'
      my_carts = current_user.carts.where(approvals: {role: @role})
    end
    @closed_carts = my_carts.closed
    @open_carts = my_carts.open
  end

  def archive
    @role = params[:role] || 'requester'
    @closed_cart_full_list = current_user.carts.where(approvals: {role: @role}).closed
  end
end