require "concerns/user_provided_services"

class OauthCredentials
  extend UserProvidedService

  def self.cg_app_id
    if use_env_var?
      ENV["CG_APP_ID"]
    else
      credentials(ENV["UPS_BASE"] + "oauth")["CG_APP_ID"]
    end
  end

  def self.cg_app_secret
    if use_env_var?
      ENV["CG_APP_SECRET"]
    else
      credentials(ENV["UPS_BASE"] + "oauth")["CG_APP_SECRET"]
    end
  end

  def self.myusa_key
    if use_env_var?
      ENV["MYUSA_KEY"]
    else
      credentials(ENV["UPS_BASE"] + "oauth")["MYUSA_KEY"]
    end
  end

  def self.myusa_secret
    if use_env_var?
      ENV["MYUSA_SECRET"]
    else
      credentials(ENV["UPS_BASE"] + "oauth")["MYUSA_SECRET"]
    end
  end
end
