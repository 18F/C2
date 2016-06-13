module ValueHelper
  include ActionView::Helpers::NumberHelper

  def date_with_tooltip(time, ago = false, opts = { truncate: false })
    # make sure we are dealing with a Time object
    unless time.is_a?(Time)
      time = Time.zone.parse(time.to_s)
    end

    # timezone adjustment is handled via browser-timezone-rails gem
    # so coerce into Time.zone explicitly
    adjusted_time = time.in_time_zone

    # if the date is today, show the time as well; otherwise only
    # show the date
    adjusted_time_str = if opts[:truncate] && !time.today?
                          adjusted_time.to_s(:pretty_date)
                        else
                          adjusted_time.to_s(:pretty_datetime)
                        end
    get_content_tag("span", adjusted_time, adjusted_time_str, ago, opts)
  end

  def property_display_value(field)
    if field.to_s == ""
      "-"
    else
      property_to_s(field)
    end
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
    else
      val
    end
  end

  def decimal?(val)
    val.is_a?(Numeric) && !val.is_a?(Integer)
  end

  private

  def get_content_tag(element, adjusted_time, adjusted_time_str, ago, opts)
    if ago
      if !adjusted_time.today? && opts[:truncate]
        content_tag(element, adjusted_time_str, title: adjusted_time_str)
      else
        content_tag(element, time_ago_in_words(adjusted_time) + " ago", title: adjusted_time_str)
      end
    else
      content_tag(element, adjusted_time_str, title: adjusted_time_str)
    end
  end
end
