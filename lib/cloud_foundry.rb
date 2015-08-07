module CloudFoundry
  def self.raw_vcap_data
    ENV['VCAP_APPLICATION']
  end

  def self.vcap_data
    if self.is_environment?
      JSON.parse(self.raw_vcap_data)
    else
      nil
    end
  end

  # returns `true` if this app is running in Cloud Foundry
  def self.is_environment?
    !!self.raw_vcap_data
  end

  def self.instance_index
    if self.is_environment?
      self.vcap_data['instance_index']
    else
      nil
    end
  end
end
