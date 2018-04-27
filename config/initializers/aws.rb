require 'aws-sdk'

Aws.config.update({
  region: AwsCredentials.region,
  credentials: Aws::Credentials.new(
    AwsCredentials.access_key_id,
    AwsCredentials.secret_access_key)
})
