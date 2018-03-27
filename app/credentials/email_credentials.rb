require "concerns/user_provided_services"

class EmailCredentials
  extend UserProvidedService

  def self.smtp_password
    if use_env_var?
      ENV["SMTP_PASSWORD"]
    else
      credentials(base_name("email"))["SMTP_PASSWORD"]
    end
  end

  def self.smtp_username
    if use_env_var?
      ENV["SMTP_USERNAME"]
    else
      credentials(base_name("email"))["SMTP_USERNAME"]
    end
  end

  def self.smtp_domain
    if use_env_var?
      ENV["SMTP_DOMAIN"]
    else
      credentials(base_name("email"))["SMTP_DOMAIN"]
    end
  end

  def self.smtp_server
    if use_env_var?
      ENV["SMTP_SERVER"]
    else
      credentials(base_name("email"))["SMTP_SERVER"]
    end
  end

  def self.smtp_port
    if use_env_var?
      ENV["SMTP_PORT"]
    else
      credentials(base_name("email"))["SMTP_PORT"]
    end
  end

  def self.smtp_auth
    if use_env_var?
      ENV["SMTP_AUTH"]
    else
      credentials(base_name("email"))["SMTP_AUTH"]
    end
  end
end
