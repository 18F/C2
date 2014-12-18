module CommunicartMailerHelper
  def status_icon_tag(status)
    image_tag("icon-#{status}.png", class: "status-icon #{status}")
  end

  def order_class(index, count)
    return "class=last" if index == count - 1
    return "class=first" if index == 0
    return ""
  end
end
