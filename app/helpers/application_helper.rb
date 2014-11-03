module ApplicationHelper
  # Variation of http://git.io/ugBzaQ
  def humanized_options_for_select(options)
    options = options.map do |key, val|
      [key.humanize, val]
    end
    options_for_select(options)
  end
end
