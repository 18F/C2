class PrepareDisplayFields
  def initialize(client_data_instance)
    @obj = { data: client_data_instance }
  end

  def run
    get_special_keys
    process_fields
  end

  def process_fields
    client_display = {}
    client_data_instance.attributes.each do |key, value|
      @obj[:key] = key
      @obj[:value] = value
      client_display[key] = modify_display
    end
    client_display
  end

  def get_special_keys
    @obj[:special_keys] = Object.const_get(@obj[:data].class).get_special_keys
  end

  def modify_display
    if @obj[:data][@obj[:key]].nil?
      "--"
    elsif @obj[:special_keys].include? @obj[:key]
      Object.const_get(@obj[:data].class).send("display_update_" + @obj[:key], @obj)
    else
      @obj[:value]
    end
  end

  private

  attr_accessor :client_data_instance
end
