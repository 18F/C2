class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  include ProposalConversationThreading

  add_template_helper MailerHelper
  add_template_helper ValueHelper
  add_template_helper ClientHelper
  add_template_helper MarkdownHelper

  before_action :add_logo

  layout "email"

  default reply_to: proc { reply_to_email }

  protected

  def add_logo
    add_inline_attachment("logo-c2-blue.png")
  end

  def add_proposal_attributes_icons
    add_inline_attachment("icon-clipped_page.png")
    add_inline_attachment("icon-speech_bubble-blue.png")
  end

  def add_inline_attachment(file_name)
    attachments.inline[file_name] = File.read(
        "app/assets/images/emails/#{file_name}"
      )
  end

  def add_approval_chain_attachments
    add_inline_number_attachment("icon-completed.png")
    add_inline_number_attachment("icon-number-1-pending.png")
    add_inline_number_attachment("icon-number-2-pending.png")
    add_inline_number_attachment("icon-number-3-pending.png")
  end

  def add_inline_number_attachment(file_name)
    attachments.inline[file_name] = File.read(
      "app/assets/images/emails/numbers/#{file_name}"
    )
  end

  def email_to_user(user)
    email_with_name(user.email_address, user.full_name)
  end

  def subject(proposal)
    if proposal.client_data_type == "Ncr::WorkOrder"
      client_data = proposal.client_data
      %(Request #{proposal.public_id}, #{client_data.organization_code_and_name}, #{client_data.building_id} from #{proposal.requester.email_address})
    else
      "Request #{proposal.public_id}"
    end
  end

  def email_with_name(email, name)
    # http://stackoverflow.com/a/8106387/358804
    address = Mail::Address.new(email)
    address.display_name = name
    address.format
  end

  def reply_email(proposal)
    reply_to_email.gsub("@", "+#{proposal.public_id}@")
  end

  def reply_to_email
    email_with_name(ENV["NOTIFICATION_REPLY_TO"] || "noreplyto@example.com", "C2")
  end

  def sender_email
    email_with_name(ENV["NOTIFICATION_FROM_EMAIL"] || "noreply@example.com", "C2")
  end

  def resend_to_email
    email_with_name(ENV["NOTIFICATION_FALLBACK_EMAIL"] || "communicart.sender@gsa.gov", "C2")
  end

  def default_sender_email
    sender_email
  end

  def user_email_with_name(user)
    email_with_name(sender_email, user.full_name)
  end
end
