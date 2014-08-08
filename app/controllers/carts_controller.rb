class CartsController < ApplicationController
  before_filter :auth_user

  def show
    cart = Cart.find params[:id]
    @cart = cart.decorate
  end

  def auth_user
    redirect_to root_url if session[:user].empty?
  end
end