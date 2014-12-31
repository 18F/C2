class CartsController < ApplicationController
  before_filter :authenticate_user!
  CLOSED_CART_LIMIT = 10

  def show
    cart = Cart.find params[:id]
    @cart = cart.decorate
    @show_comments = true
  end

  def index
    role = 'requester'
    my_carts = Cart.joins(:approvals).where(:approvals => {:role => role, :user_id => @current_user[:id]})
    if my_carts.empty?
      role = 'approver'
      my_carts = Cart.joins(:approvals).where(:approvals => {:role => role, :user_id => @current_user[:id]})
    end
    @closed_carts = my_carts.closed
    @open_carts = my_carts.open
    render :template => "carts/index", :locals => {:open_carts => @open_carts,
                                                   :closed_carts => @closed_carts,
                                                   :user => @current_user, :role => role,
                                                   limit: CLOSED_CART_LIMIT}
  end

  def archive
    role = params[:role] || 'requester'
    @closed_cart_full_list = Cart.joins(:approvals).where(:approvals => {:role => role, :user_id => @current_user[:id]}).closed
    render :template => "carts/archive", :locals => {:closed_carts => @closed_cart_full_list, :user => @current_user, :role => role}
  end
end