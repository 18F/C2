class CartsController < ApplicationController
  before_filter :authenticate_user!

  def show
    cart = Cart.find params[:id]
    @cart = cart.decorate
    @show_comments = true
  end

  def index
    @closed_cart_limit = 10
    @user = User.find(params[:id])
    @role = 'requester'
    my_carts = Cart.joins(:approvals).where(:approvals => {:role => @role, :user_id => params[:id]})
    if my_carts.empty?
      @role = 'approver'
      my_carts = Cart.joins(:approvals).where(:approvals => {:role => @role, :user_id => params[:id]})
    end
    @closed_carts = my_carts.closed
    @open_carts = my_carts.open
    render :template => "users/index"
  end

end