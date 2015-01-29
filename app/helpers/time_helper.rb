module TimeHelper
  def human_readable_time(t1)
    offset = self.default_time_zone_offset
    t1.utc.getlocal(offset).asctime
  end
  module_function :human_readable_time

  def default_time_zone_offset
    '-04:00'
  end
  module_function :default_time_zone_offset

  def date_with_tooltip(time)
    content_tag('span', l(time.to_date), title: l(time))
  end
end
