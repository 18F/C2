require 'aws-sdk'

creds = Aws::SharedCredentials.new
aws_key = creds.access_key_id
aws_secret = creds.secret_access_key

if aws_key && aws_secret
  set :aws_access_key_id, aws_key
  set :aws_secret_access_key, aws_secret
  set :aws_region, 'us-west-2'
else
  raise "Please set up an AWS access key for Capistrano use – see http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration."
end
