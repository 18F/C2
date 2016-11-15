require 'concerns/user_provided_services'

class EnvCredentials
  extend UserProvidedService

  def self.api_enabled
    if use_env_var?
      ENV["API_ENABLED"]
    else
      credentials('API_ENABLED')
    end
  end

  def self.welcome_email
    if use_env_var?
      ENV["WELCOME_EMAIL"]
    else
      credentials('WELCOME_EMAIL')
    end
  end

  def self.beta_18f_training
    if use_env_var?
      ENV["BETA_18F_TRAINING"]
    else
      credentials('BETA_18F_TRAINING')
    end
  end

  def self.beta_feature_detail_view
    if use_env_var?
      ENV["BETA_FEATURE_DETAIL_VIEW"]
    else
      credentials('BETA_FEATURE_DETAIL_VIEW')
    end
  end

  def self.beta_feature_list_view
    if use_env_var?
      ENV["BETA_FEATURE_LIST_VIEW"]
    else
      credentials('BETA_FEATURE_LIST_VIEW')
    end
  end

  def self.redesign_default_view
    if use_env_var?
      ENV["REDESIGN_DEFAULT_VIEW"]
    else
      credentials('REDESIGN_DEFAULT_VIEW')
    end
  end

  def self.asset_host
    if use_env_var?
      ENV["ASSET_HOST"]
    else
      credentials('ASSET_HOST')
    end
  end

  def self.default_url_host
    if use_env_var?
      ENV["DEFAULT_URL_HOST"]
    else
      credentials('DEFAULT_URL_HOST')
    end
  end

  def self.cg_app_id
    if use_env_var?
      ENV["CG_APP_ID"]
    else
      credentials('CG_APP_ID')
    end
  end

  def self.cg_app_secret
    if use_env_var?
      ENV["CG_APP_SECRET"]
    else
      credentials('CG_APP_SECRET')
    end
  end

  def self.myusa_key
    if use_env_var?
      ENV["MYUSA_KEY"]
    else
      credentials('MYUSA_KEY')
    end
  end

  def self.myusa_secret
    if use_env_var?
      ENV['MYUSA_SECRET']
    else
      credentials('MYUSA_SECRET')
    end
  end

  def self.new_relic_agent_enabled
    if use_env_var?
      ENV["NEW_RELIC_AGENT_ENABLED"]
    else
      credentials('NEW_RELIC_AGENT_ENABLED')
    end
  end

  def self.new_relic_app_name
    if use_env_var?
      ENV["NEW_RELIC_APP_NAME"]
    else
      credentials('NEW_RELIC_APP_NAME')
    end
  end

  def self.new_relic_license_key
    if use_env_var?
      ENV['NEW_RELIC_LICENSE_KEY']
    else
      credentials('NEW_RELIC_LICENSE_KEY')
    end
  end

  def self.s3_bucket_name
    if use_env_var?
      ENV["S3_BUCKET_NAME"]
    else
      credentials('S3_BUCKET_NAME')
    end
  end

  def self.s3_region
    if use_env_var?
      ENV["S3_REGION"]
    else
      credentials('S3_REGION')
    end
  end

  def self.secret_token
    if use_env_var?
      ENV["SECRET_TOKEN"]
    else
      credentials('SECRET_TOKEN')
    end
  end

  def self.notification_from_email
    if use_env_var?
      ENV["NOTIFICATION_FROM_EMAIL"]
    else
      credentials('NOTIFICATION_FROM_EMAIL')
    end
  end

  def self.notification_reply_to
    if use_env_var?
      ENV["NOTIFICATION_REPLY_TO"]
    else
      credentials('NOTIFICATION_REPLY_TO')
    end
  end

  def self.smtp_password
    if use_env_var?
      ENV["SMTP_PASSWORD"]
    else
      credentials('SMTP_PASSWORD')
    end
  end

  def self.smtp_username
    if use_env_var?
      ENV["SMTP_USERNAME"]
    else
      credentials('SMTP_USERNAME')
    end
  end
end
