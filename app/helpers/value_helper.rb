module ValueHelper
  def date_with_tooltip(time)
    adjusted_time = time.in_time_zone("Eastern Time (US & Canada)").strftime("%b %-d, %Y at %l:%M%P")
    content_tag('span', adjusted_time, title: adjusted_time)
  end

  def decimal?(val)
    val.is_a?(Numeric) && !val.is_a?(Integer)
  end

  def property_to_s(val)
    # assume all decimals are currency
    if decimal?(val)
      number_to_currency(val)
    else
      val.to_s
    end
  end
end
