module MailerHelper
  def property_display_value(field)
    if field.nil?
      "-"
    else
      property_to_s(field)
    end
  end

  def time_and_date(date)
    "#{date.strftime('%m/%d/%Y')} at #{date.strftime('%I:%M %P')}"
  end

  def generate_approve_url(approval)
    proposal = approval.proposal
    opts = { version: proposal.version, cch: approval.api_token.access_token }
    complete_proposal_url(proposal, opts)
  end

  def add_author(text, user)
    if user
      text << " by #{user.full_name}"
    end
  end

  def add_reason(text, reason)
    if reason.present?
      text << t("mailer.reason", reason: reason)
    end
  end

  def step_status_icon(step)
    if step.status == "actionable"
      "emails/numbers/icon-number-" + (step.position - 1).to_s + ".png"
    elsif step.status == "pending"
      "emails/numbers/icon-number-" + (step.position - 1).to_s + "-pending.png"
    elsif step.status == "completed"
      "emails/numbers/icon-completed.png"
    end
  end

  def step_user_title(step)
    step.decorate.role_name
  end
end
