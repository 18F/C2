require "concerns/user_provided_service"s

class AppParamCredentials
  extend UserProvidedService

  def self.asset_host
    if use_env_var?
      ENV["ASSET_HOST"]
    else
      credentials(ENV["UPS_BASE"] + "app_param")["ASSET_HOST"]
    end
  end

  def self.default_url_host
    if use_env_var?
      ENV["DEFAULT_URL_HOST"]
    else
      credentials(ENV["UPS_BASE"] + "app_param")["DEFAULT_URL_HOST"]
    end
  end

  def self.secret_token
    if use_env_var?
      ENV["SECRET_TOKEN"]
    else
      credentials(ENV["UPS_BASE"] + "app_param")["SECRET_TOKEN"]
    end
  end
end
