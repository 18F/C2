module ControllerSpecHelper
  def login_as(user)
    session[:user] = {
      'email' => user.email_address
    }
  end
end
