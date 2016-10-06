class PrepareDisplayFields
  def initialize(value, key, client_data_instance, data)
    @data = data
    @value = value
    @key = key
    @client_data_instance = client_data_instance
  end

  def run
    if data[key].nil?
      "--"
    elsif special_keys.include? key
      self.send("display_update_" + key, value, key, client_data_instance)
    else
      value
    end
    Object.const_get(@proposal.client_data_type).prepare_frontend(@client_data)
  end

  private

  attr_accessor :value, :key, :client_data_instance
end
