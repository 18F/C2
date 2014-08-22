class CartsController < ApplicationController
  before_filter :authenticate_user!

  def show
    cart = Cart.find params[:id]
    @cart = cart.decorate
  end

end