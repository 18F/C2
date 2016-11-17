require "concerns/user_provided_services"

class NewrelicCredentials
  extend UserProvidedService

  def self.new_relic_app_name
    if use_env_var?
      ENV["NEW_RELIC_APP_NAME"]
    else
      credentials("NEW_RELIC_APP_NAME")
    end
  end

  def self.new_relic_license_key
    if use_env_var?
      ENV["NEW_RELIC_LICENSE_KEY"]
    else
      credentials("NEW_RELIC_LICENSE_KEY")
    end
  end
end
