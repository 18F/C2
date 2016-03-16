class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  include ProposalConversationThreading

  add_template_helper MailerHelper
  add_template_helper ValueHelper
  add_template_helper ClientHelper
  add_template_helper MarkdownHelper

  layout "email"

  default reply_to: proc { reply_to_email }

  protected

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
