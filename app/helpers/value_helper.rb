module ValueHelper
  def date_with_tooltip(time)
    content_tag('span', l(time.to_date), title: l(time))
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
