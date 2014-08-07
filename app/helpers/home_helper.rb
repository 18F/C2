module HomeHelper
  def signed_in?
    !session[:user].empty?
  end
end
