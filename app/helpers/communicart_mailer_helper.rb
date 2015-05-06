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

  def generate_approve_url(approval)
    proposal = approval.proposal
    opts = { version: proposal.version }
    if auto_login?(approval.user)
      opts[:cch] = approval.api_token.access_token
    end

    approve_proposal_url(proposal, opts)
  end
end
