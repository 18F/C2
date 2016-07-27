module FormHelper
  # Variation of https://git.io/ugBzaQ
  def humanized_options_for_select(options)
    options = options.map do |val|
      [val.humanize, val]
    end
    options_for_select(options)
  end

  def bootstrap_alert_map
    {
      notice: "info",
      error: "danger",
      alert: "warning"
    }
  end

  def bootstrap_alert_class(key)
    suffix = bootstrap_alert_map[key.to_sym] || key
    "bg-#{suffix}"
  end

  def flash_list
    flash.map do |key, message|
      [key, flash_message_html(message)]
    end
  end

  def flash_message_html(message)
    if message.respond_to? :map
      [
        "<ul>",
        message.map { |err| "<li>#{err}.</li>" },
        "</ul>"
      ].join.html_safe
    else
      message
    end
  end

  def popover_data_attrs(key)
    {
      toggle: "popover", trigger: "focus", html: true, placement: "top",
      title: I18n.t("helpers.popover.#{key}.title"),
      content: I18n.t("helpers.popover.#{key}.content")
    }
  end
end
