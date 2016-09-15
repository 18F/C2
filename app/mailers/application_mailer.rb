class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  include ActionMailer::Text
  include ProposalConversationThreading
  include MailAddressing

  add_template_helper MailerHelper
  add_template_helper ValueHelper
  add_template_helper ClientHelper
  add_template_helper MarkdownHelper

  before_action :add_logo

  layout "email"

  default reply_to: proc { reply_to_email }

  # Allow email to be disabled in test by setting
  # `ActionMailer::Base.perform_deliveries = false`
  #
  # @Overrides ActionMailer::Base#mail
  def mail(headers, &hash)
    return if Rails.env.test? && !ActionMailer::Base.perform_deliveries
    super
  end

  protected

  def send_email(to:, proposal:, from: default_sender_email)
    mail(
      to: email_to_user(to),
      subject: subject(proposal),
      from: from,
      reply_to: reply_email(proposal)
    )
  end

  def email_to_user(user)
    email_with_name(user.email_address, user.full_name)
  end

  def add_logo
    add_inline_attachment("logo-c2-blue.png")
  end

  def add_proposal_attributes_icons(proposal)
    add_inline_attachment("icon-clipped_page.png") if proposal.attachments.any?

    if proposal.comments.any?
      add_inline_attachment("icon-speech_bubble-blue.png")
    end

    add_approval_chain_attachments(proposal)
  end

  def add_approval_chain_attachments(proposal)
    add_completed_icon(proposal)
    add_pending_icons(proposal)
  end

  def add_completed_icon(proposal)
    if proposal.individual_steps.completed.any? && proposal.individual_steps.length > 1
      add_inline_number_icon_attachment("icon-completed.png")
    end
  end

  def add_pending_icons(proposal)
    proposal.individual_steps.each do |proposal_step|
      next if proposal_step.status == "completed"
      add_inline_number_icon_attachment(
        "icon-number-" + (proposal_step.position - 1).to_s + "-pending.png"
      )
    end
  end

  def add_inline_number_icon_attachment(file_name)
    attachments.inline[file_name] = File.read(
      "app/assets/images/numbers/#{file_name}"
    )
  end

  def add_inline_attachment(file_name)
    attachments.inline[file_name] = File.read(
      "app/assets/images/emails/#{file_name}"
    )
  end

  def subject(proposal)
    if proposal.client_data_type == "Ncr::WorkOrder"
      client_data = proposal.client_data
      %(Request #{proposal.public_id}, #{client_data.organization_code_and_name}, #{client_data.building_id} from #{proposal.requester.email_address})
    else
      "Request #{proposal.public_id}"
    end
  end
end
