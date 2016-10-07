class PrepareDisplayFields
  def initialize(display_fields)
    @obj = display_fields
  end

  def run
    if @obj[:data][@obj[:key]].nil?
      "--"
    elsif special_keys.include? @obj[:key]
      Object.const_get(@obj[:data].class).send("display_update_" + @obj[:key], @obj)
    else
      @obj[:value]
    end
  end

  private

  attr_accessor :display_fields
end
