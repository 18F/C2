class UsersController < ApplicationController
  def find_carts_for_user
    @user = User.find(params[:id])
    @my_carts = Cart.joins(:approvals).where(:approvals => {:role => 'requester', :user_id => params[:id]})
    # @approver_carts = Cart.joins(:approvals).where(:approvals => {:role => 'approver', :user_id => params[:id]})
    @closed_carts = @my_carts.closed
    @open_carts = @my_carts.open
    render :template => "users/index"
  end
end