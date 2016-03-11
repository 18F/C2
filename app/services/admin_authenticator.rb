module AdminAuthenticator
  module_function

  def require_admin
    if current_user.nil? || current_user.not_admin?
      render "authorization_error", status: 403
    end
  end
end
