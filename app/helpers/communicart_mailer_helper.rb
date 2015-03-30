module CommunicartMailerHelper
  def status_icon_tag(status, linear=false)
    image_tag("icon-#{status}.png", class: "status-icon #{status} #{'linear' if linear}")
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

  def approval_action_url(approval, action = 'approve')
    approval_response_url(
      cart_id: approval.cart_id,
      cch: approval.api_token.access_token,
      version: approval.proposal.version,
      approver_action: action
    )
  end
end
