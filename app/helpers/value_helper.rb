module ValueHelper
  include ActionView::Helpers::NumberHelper

  def date_with_tooltip(time, ago = false)
    # make sure we are dealing with a Time object
    unless time.is_a?(Time)
      time = Time.zone.parse(time.to_s)
    end

    # timezone adjustment is handled via browser-timezone-rails gem
    # so coerce into Time.zone explicitly
    adjusted_time = time.in_time_zone
    adjusted_time_str = adjusted_time.strftime("%b %-d, %Y at %l:%M%P")

    if ago
      content_tag("span", time_ago_in_words(adjusted_time) + " ago", title: adjusted_time_str)
    else
      content_tag("span", adjusted_time_str, title: adjusted_time_str)
    end
  end

  def decimal?(val)
    val.is_a?(Numeric) && !val.is_a?(Integer)
  end

  def property_to_s(val)
    if decimal?(val) # assume all decimals are currency
      number_to_currency(val)
    elsif val.is_a?(ActiveSupport::TimeWithZone)
      I18n.l(val, format: :date)
    elsif val == true
      "Yes"
    elsif val == false
      "No"
    elsif val.present?
      val
    else
      "-"
    end
  end
end
