module ApplicationHelper
  # Variation of http://git.io/ugBzaQ
  def enum_option_pairs(record, enum)
    reader = enum.to_s.pluralize
    record = record.class unless record.respond_to?(reader)
    options = record.send(reader)
    options = options.map do |key, val|
      [key.humanize, val]
    end
    options_for_select(options)
  end
end
