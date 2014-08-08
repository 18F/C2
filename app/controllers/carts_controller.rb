class CartsController < ApplicationController
  def show
    cart = Cart.find params[:id]
    @cart = cart.decorate
  end
end