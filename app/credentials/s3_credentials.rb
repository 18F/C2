require "concerns/user_provided_services"

class S3Credentials
  extend UserProvidedService

  def self.s3_secret_access_key
    if use_env_var?
      ENV["S3_SECRET_ACCESS_KEY"]
    else
      credentials(base_name("s3"))["S3_SECRET_ACCESS_KEY"]
    end
  end

  def self.s3_access_key_id
    if use_env_var?
      ENV["S3_ACCESS_KEY_ID"]
    else
      credentials(base_name("s3"))["S3_ACCESS_KEY_ID"]
    end
  end

  def self.s3_bucket_name
    if use_env_var?
      ENV["S3_BUCKET_NAME"]
    else
      credentials(base_name("s3"))["S3_BUCKET_NAME"]
    end
  end

  def self.s3_region
    if use_env_var?
      ENV["S3_REGION"]
    else
      credentials(base_name("s3"))["S3_REGION"]
    end
  end
end
