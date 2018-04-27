require "concerns/user_provided_services"

class AwsCredentials
  extend UserProvidedService

  def self.access_key_id
    if use_env_var?
      ENV['AWS_ACCESS_KEY_ID']
    else
      credentials(base_name("aws"))["AWS_ACCESS_KEY_ID"]
    end
  end

  def self.secret_access_key
    if use_env_var?
      ENV['AWS_SECRET_ACCESS_KEY']
    else
      credentials(base_name("aws"))["AWS_SECRET_ACCESS_KEY"]
    end
  end

  def self.region
    if use_env_var?
      ENV['AWS_REGION'] || 'us-east-1'
    else
      credentials(base_name("aws"))["AWS_REGION"] || 'us-east-1'
    end
  end
end
