# This custom delivery method was created because of the way the AWS client
# libraries share credentials. Instead of inheriting the Aws.config hash, we
# explicitly set the Aws::SES::Client's credentials here to avoid collision
# with the Paperclip gem's AWS configuration.
#
#
# taken from aws-sdk-rails gem's original source here:
# https://github.com/aws/aws-sdk-rails/blob/master/lib/aws/rails/mailer.rb
require 'aws-sdk-ses'

class SesMailDelivery
  def initialize(options = {})
    @client = Aws::SES::Client.new(region: AwsCredentials.region,
      credentials: Aws::Credentials.new(
        AwsCredentials.access_key_id,
        AwsCredentials.secret_access_key))
  end

  # Rails expects this method to exist, and to handle a Mail::Message object
  # correctly. Called during mail delivery.
  def deliver!(message)
    send_opts = {}
    send_opts[:raw_message] = {}
    send_opts[:raw_message][:data] = message.to_s

    if message.respond_to?(:destinations)
      send_opts[:destinations] = message.destinations
    end

    @client.send_raw_email(send_opts)

  end

  # ActionMailer expects this method to be present and to return a hash.
  def settings
    {}
  end

end
