module ApplicationHelper
  # Variation of http://git.io/ugBzaQ
  def humanized_options_for_select(options)
    options = options.map do |val|
      [val.humanize, val]
    end
    options_for_select(options)
  end

  def controller_name
    params[:controller].gsub(/\W/, '-')
  end

  def bootstrap_alert_class(key)
    case key.to_sym
    when :error
      'bg-danger'
    else
      "bg-#{key}"
    end
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
end
