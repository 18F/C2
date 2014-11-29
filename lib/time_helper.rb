module TimeHelper
  def self.human_readable_time(t1)
    offset = self.default_time_zone_offset
    t1.utc.getlocal(offset).asctime
  end

  def self.default_time_zone_offset
    '-04:00'
  end
end
