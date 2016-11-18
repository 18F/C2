require "concerns/user_provided_services"

class EmailCredentials
  extend UserProvidedService

  def self.smtp_password
    if use_env_var?
      ENV["SMTP_PASSWORD"]
    else
      credentials(ENV["UPS_BASE"] + "email")["SMTP_PASSWORD"]
    end
  end

  def self.smtp_username
    if use_env_var?
      ENV["SMTP_USERNAME"]
    else
      credentials(ENV["UPS_BASE"] + "email")["SMTP_USERNAME"]
    end
  end
end
