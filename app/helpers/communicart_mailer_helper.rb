module CommunicartMailerHelper
  def status_icon_tag(status)
    image_tag("icon-#{status}.png", class: "status-icon #{status}")
  end

  def generate_bookend_class(index, count)
    return "class=last" if index == count - 1
    return "class=first" if index == 0
    return ""
  end
end
