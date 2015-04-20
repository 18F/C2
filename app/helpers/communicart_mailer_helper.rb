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

  # If the user has delegates, returns `false` so that the email can be safely forwarded.
  def auto_login?(user)
    user.outgoing_delegates.empty?
  end

  def approval_action_url(approval, action = 'approve')
    opts = {
      cart_id: approval.cart_id,
      version: approval.proposal.version,
      approver_action: action
    }
    if auto_login?(approval.user)
      opts[:cch] = approval.api_token.access_token
    end

    approval_response_url(opts)
  end
end
