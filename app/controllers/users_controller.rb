class UsersController < ApplicationController

  def find_carts_for_user
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