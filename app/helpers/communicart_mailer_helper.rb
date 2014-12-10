module CommunicartMailerHelper
  def status_icon_tag(status)
    image_tag("icon-#{status}.png", class: 'status-icon')
  end
end
