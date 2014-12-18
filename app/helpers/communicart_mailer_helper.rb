module CommunicartMailerHelper
  def status_icon_tag(status)
    image_tag("icon-#{status}.png", class: "status-icon #{status}")
  end

  def generate_bookend_class(index, count)
    case index
    when count - 1
      'class=last'
    when 0
      'class=first'
    else
      ''
    end
  end
end
