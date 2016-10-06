class PrepareDisplayFields
  def initialize(value, key,  data)
    @value = value
    @key = key
    @data = data
  end

  def run
    if @data[@key].nil?
      "--"
    elsif special_keys.include? key
      Object.const_get(@data.class).send("display_update_" + key, value, key, data)
    else
      value
    end
  end

  private

  attr_accessor :value, :key, :client_data_instance
end
