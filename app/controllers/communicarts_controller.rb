class CommunicartsController < ApplicationController
  def send cart
    @user = User.create(email: 'raphael.vilas@gmail.com')
    CommunicartMailer.cart_notification_email(@User).deliver
  end
end
