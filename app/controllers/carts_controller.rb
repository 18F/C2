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
    @role = requester_or_approver
    @carts = current_user.carts.order('created_at DESC')
  end

  def archive
    @role = params[:role] || 'requester'
    @closed_cart_full_list = current_user.carts.where(approvals: {role: @role}).closed.order('created_at DESC')
  end

  private

  def requester_or_approver
    ['requester','approver'].each do |role|
      break role if current_user.carts.where(approvals: { role: role }).any?
    end
  end
end