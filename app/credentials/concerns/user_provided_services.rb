module UserProvidedService
  def credentials(service_name)
    user_provided_service[service_name]
  end

  def use_env_var?
    Rails.env.development? || Rails.env.test?
  end

  def user_provided_service
    vcap_services['user-provided'][0]['credentials']
  end

  def vcap_services
    JSON.parse(ENV['VCAP_SERVICES'])
  end
end
