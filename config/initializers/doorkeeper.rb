Doorkeeper.configure do
  orm :active_record

  enable_application_owner confirmation: true

  resource_owner_authenticator do
    if session[:user] && session[:user]["email"]
      User.find_by(email_address: session[:user]["email"])
    else
      warden.authenticate!(scope: :user)
    end
  end
end
