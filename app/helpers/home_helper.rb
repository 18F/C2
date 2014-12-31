module HomeHelper
  def signed_in?
    session[:user] && !session[:user].empty?
  end
end
