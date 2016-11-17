require "concerns/user_provided_services"

class OauthCredentials
  extend UserProvidedService

  def self.cg_app_id
    if use_env_var?
      ENV["CG_APP_ID"]
    else
      credentials("CG_APP_ID")
    end
  end

  def self.cg_app_secret
    if use_env_var?
      ENV["CG_APP_SECRET"]
    else
      credentials("CG_APP_SECRET")
    end
  end

  def self.myusa_key
    if use_env_var?
      ENV["MYUSA_KEY"]
    else
      credentials("MYUSA_KEY")
    end
  end

  def self.myusa_secret
    if use_env_var?
      ENV["MYUSA_SECRET"]
    else
      credentials("MYUSA_SECRET")
    end
  end
end
