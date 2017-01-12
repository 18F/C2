require "concerns/user_provided_services"

class S3Credentials
  extend UserProvidedService

  def self.s3_secret_access_key
    if use_env_var?
      ENV["S3_SECRET_ACCESS_KEY"]
    else
      vcap_services["s3"][0]["credentials"]["secret_access_key"]

    end
  end

  def self.s3_access_key_id
    if use_env_var?
      ENV["S3_ACCESS_KEY_ID"]
    else
      vcap_services["s3"][0]["credentials"]["access_key_id"]
    end
  end

  def self.s3_bucket_name
    if use_env_var?
      ENV["S3_BUCKET_NAME"]
    else
      vcap_services["s3"][0]["credentials"]["bucket"]
    end
  end

  def self.s3_region
    if use_env_var?
      ENV["S3_REGION"]
    else
      vcap_services["s3"][0]["credentials"]["region"]
    end
  end
end
