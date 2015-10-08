module UiHelper
  # Variation of https://git.io/ugBzaQ
  def humanized_options_for_select(options)
    options = options.map do |val|
      [val.humanize, val]
    end
    options_for_select(options)
  end

  def bootstrap_alert_class(key)
    suffix = case key.to_sym
             when :notice
               'info'
             when :error
               'danger'
             else
               key
             end

    "bg-#{suffix}"
  end

  def flash_message(val)
    if val.is_a?(Enumerable)
      val.join('. ')
    else
      val
    end
  end

  def flash_list
    flash.map do |key, val|
      [key, flash_message(val)]
    end
  end

  def popover_data_attrs(key)
    { toggle: 'popover', trigger: 'focus', html: true, placement: 'top',
      title: I18n.t("helpers.popover.#{key}.title"),
      content: I18n.t("helpers.popover.#{key}.content")
    }
  end
end
