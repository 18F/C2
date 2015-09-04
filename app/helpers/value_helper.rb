module ValueHelper
  include ActionView::Helpers::NumberHelper

  def date_with_tooltip(time, ago = false)
    # make sure we are dealing with a Time object
    unless time.is_a?(Time)
      time = Time.zone.parse(time)
    end

    # timezone adjustment is handled via browser-timezone-rails gem
    # so coerce into Time.zone explicitly
    adjusted_time = time.in_time_zone.strftime("%b %-d, %Y at %l:%M%P")

    if ago
      content_tag('span', time_ago_in_words(adjusted_time) + " ago", title: adjusted_time)
    else
      content_tag('span', adjusted_time, title: adjusted_time)
    end
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
