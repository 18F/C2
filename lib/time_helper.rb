module TimeHelper
  def human_readable_time(t1,offset)
    return t1.utc.getlocal(offset).asctime
  end

  def default_time_zone_offset
    return "-04:00"
  end
end
