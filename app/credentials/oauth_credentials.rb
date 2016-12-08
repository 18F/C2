require "concerns/user_provided_services"

class OauthCredentials
  extend UserProvidedService

  def self.cg_app_id
    if use_env_var?
      ENV["CG_APP_ID"]
    else
      credentials(base_name("oauth"))["CG_APP_ID"]
    end
  end

  def self.cg_app_secret
    if use_env_var?
      ENV["CG_APP_SECRET"]
    else
      credentials(base_name("oauth"))["CG_APP_SECRET"]
    end
  end
end
