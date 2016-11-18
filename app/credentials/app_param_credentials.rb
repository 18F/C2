require "concerns/user_provided_services"

class AppParamCredentials
  extend UserProvidedService

  def self.asset_host
    ENV["ASSET_HOST"]
  end

  def self.default_url_host
    if use_env_var?
      ENV["DEFAULT_URL_HOST"]
    else
      credentials(base_name("app_param"))["DEFAULT_URL_HOST"]
    end
  end

  def self.secret_token
    if use_env_var?
      ENV["SECRET_TOKEN"]
    else
      credentials(base_name("app_param"))["SECRET_TOKEN"]
    end
  end
end
