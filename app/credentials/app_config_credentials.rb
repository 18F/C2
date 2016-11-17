require "concerns/user_provided_services"

class AppConfigCredentials
  extend UserProvidedService

  def self.api_enabled
    if use_env_var?
      ENV["API_ENABLED"]
    else
      credentials("API_ENABLED")
    end
  end

  def self.welcome_email
    if use_env_var?
      ENV["WELCOME_EMAIL"]
    else
      credentials("WELCOME_EMAIL")
    end
  end

  def self.beta_18f_training
    if use_env_var?
      ENV["BETA_18F_TRAINING"]
    else
      credentials("BETA_18F_TRAINING")
    end
  end

  def self.beta_feature_detail_view
    if use_env_var?
      ENV["BETA_FEATURE_DETAIL_VIEW"]
    else
      credentials("BETA_FEATURE_DETAIL_VIEW")
    end
  end

  def self.beta_feature_list_view
    if use_env_var?
      ENV["BETA_FEATURE_LIST_VIEW"]
    else
      credentials("BETA_FEATURE_LIST_VIEW")
    end
  end

  def self.redesign_default_view
    if use_env_var?
      ENV["REDESIGN_DEFAULT_VIEW"]
    else
      credentials("REDESIGN_DEFAULT_VIEW")
    end
  end
end
