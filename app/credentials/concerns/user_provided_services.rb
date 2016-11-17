module UserProvidedService
  def credentials(service_name)
    user_provided_service(service_name)['credentials']
  end

  def use_env_var?
    Rails.env.development? || Rails.env.test?
  end

  def user_provided_service(name)
    user_provided_services.find { |service| service['name'] == name }
  end

  def user_provided_services
    vcap_services['user-provided']
  end

  def vcap_services
    JSON.parse(ENV['VCAP_SERVICES'])
  end
end
